defmodule BackendWeb.Resolvers.ConversationResolver do
  import Ecto.Query

  alias Backend.Conversations
  alias Backend.Conversations.Conversation
  alias Backend.Conversations.Message
  alias Backend.Repo
  alias BackendWeb.Resolvers
  alias BackendWeb.Endpoint
  alias Absinthe.Subscription

  @from_number Application.get_env(:backend, :telnyx_number)
  @status_url Application.get_env(:backend, :status_url)
  @telnyx_api_key Application.get_env(:backend, :telnyx_api_key)

  require Logger

  # def get_conversations(_, %{context: %{authenticated?: true}}) do
  #   {:ok, Conversations.list_conversations()}
  # end

  # def get_conversations(_, _) do
  #   {:error, "unauthorized"}
  # end

  def get_conversations_ordered(args, %{context: %{authenticated?: true}}) do
    most_recent_messages =
      from(m in Message,
        group_by: m.conversation_id,
        select: %{inserted_at: max(m.inserted_at), conversation_id: m.conversation_id},
        distinct: m.conversation_id
      )

    query =
      from(c in Conversation,
        left_join: most_recent in subquery(most_recent_messages),
        on: most_recent.conversation_id == c.id,
        join: most_recent_full in Message,
        on:
          most_recent_full.conversation_id == most_recent.conversation_id and
            most_recent_full.inserted_at == most_recent.inserted_at,
        order_by: [desc: most_recent.inserted_at],
        select_merge: %{most_recent_message: most_recent_full},
        limit: 10
      )

    search = Map.get(args, :search)

    query =
      if search do
        term = "%#{search}%"
        from([c, ...] in query, where: ilike(c.name, ^term) or ilike(c.number, ^term))
      else
        query
      end

    cursor = Map.get(args, :cursor)

    query =
      if cursor && !search do
        {:ok, timestamp} = NaiveDateTime.from_iso8601(cursor)
        from([_, most_recent, ...] in query, where: most_recent.inserted_at < ^timestamp)
      else
        query
      end

    preload = [messages: from(m in Message, order_by: [desc: m.inserted_at])]
    conversations = Conversations.list_conversations(query: query, preloads: preload)

    new_cursor =
      conversations
      |> List.last()
      |> case do
        nil -> cursor
        %{most_recent_message: %{inserted_at: inserted_at}} -> inserted_at
      end

    {:ok, %{conversations: conversations, cursor: new_cursor}}
  end

  def get_conversations_ordered(_, _) do
    {:error, "unauthorized"}
  end

  def get_conversation_by_id(%{id: nil}, %{context: %{authenticated?: true}}) do
    {:ok, nil}
  end

  def get_conversation_by_id(%{id: id}, %{context: %{authenticated?: true}}) do
    {:ok, Conversations.get_conversation_by_id(id, preloads: [:messages])}
  end

  def get_conversation_by_id(_, _) do
    {:error, "unauthorized"}
  end

  def get_conversation_by_number(%{number: number}, %{context: %{authenticated?: true}}) do
    with {:ok, formatted_number} <- Conversations.format_number(number),
         {:ok, conversation} <- Conversations.get_conversation_by_number(formatted_number) do
      {:ok, conversation}
    end
  end

  def get_conversation_by_number(_, _) do
    {:error, "unauthorized"}
  end

  def get_cloudinary_url(_, %{context: %{authenticated?: true}}) do
    cloudinary_key = System.get_env("CLOUDINARY_URL")

    api_key = cloudinary_key && cloudinary_key |> String.split("@") |> List.last()

    {:ok, %{url: "https://api.cloudinary.com/v1_1/#{api_key}/upload"}}
  end

  def get_cloudinary_url(_, _) do
    {:error, "unauthorized"}
  end

  def create_conversation(_, args, %{context: %{authenticated?: true}}) do
    case Conversations.create_conversation(args) do
      {:ok, conversation} -> {:ok, conversation}
      {:error, changeset} -> {:error, Resolvers.format_changeset_errors(changeset.errors)}
    end
  end

  def create_conversation(_, _, _) do
    {:error, "unauthorized"}
  end

  def conversation_read(_, %{id: id}, %{context: %{authenticated?: true}}) do
    conversation = Conversations.get_conversation_by_id(id)

    with convo when not is_nil(convo) <- conversation,
         {:ok, convo} <- Conversations.update_conversation(convo, %{unread_at: nil}) do
      {:ok, convo}
    else
      _ -> {:error, "Error updating unread_at"}
    end
  end

  def conversation_read(_, _, _) do
    {:error, "unauthorized"}
  end

  def create_conversation_and_message(_, args, %{context: %{authenticated?: true}}) do
    number = Map.get(args, :number)
    body = Map.get(args, :body)
    url = Map.get(args, :attachment_url)
    url_type = Map.get(args, :url_type)
    direction = "outbound"
    status = "sending"

    Repo.transaction(fn ->
      {:ok, conversation} = Conversations.create_conversation(%{number: number})

      if body in [nil, ""] and !url do
        Repo.rollback("body or attachment_url required")
      else
        attachment_attrs = %{
          conversation_id: conversation.id,
          attachment_url: url,
          direction: direction,
          status: status,
          type: url_type
        }

        attachment_result =
          with true <- url not in [nil, ""],
               {:ok, message} <- Conversations.create_message(attachment_attrs),
               {:ok, %{"id" => id}} <- send_attachment(conversation, url),
               {:ok, message} <-
                 Conversations.update_message(message, %{external_id: id},
                   preloads: [:conversation]
                 ) do
            Subscription.publish(Endpoint, message, message_added: "message.added")
            message
          else
            _ -> :error
          end

        text_attrs = %{
          conversation_id: conversation.id,
          body: body,
          direction: direction,
          status: status,
          type: "text"
        }

        text_result =
          with true <- body not in [nil, ""],
               {:ok, message} <- Conversations.create_message(text_attrs),
               {:ok, %{"id" => id}} <- send_text(conversation, body),
               {:ok, message} <-
                 Conversations.update_message(message, %{external_id: id},
                   preloads: [:conversation]
                 ) do
            Subscription.publish(Endpoint, message, message_added: "message.added")
            message
          else
            _ -> :error
          end

        messages = Enum.filter([text_result, attachment_result], &(&1 != :error))

        conversation =
          conversation
          |> Map.put(:messages, messages)
          |> Map.put(:most_recent_message, List.last(messages))

        {:ok, conversation}
      end
    end)
    |> case do
      {:ok, return_value} -> return_value
      {:error, error} -> {:error, error}
    end
  end

  def create_conversation_and_message(_, _, _) do
    {:error, "unauthorized"}
  end

  def update_conversation_name(_, args = %{id: id}, %{context: %{authenticated?: true}}) do
    args = if args[:name], do: args, else: Map.put(args, :name, nil)

    with convo when not is_nil(convo) <- Conversations.get_conversation_by_id(id) do
      case Conversations.update_conversation(convo, args) do
        {:ok, conversation} ->
          Subscription.publish(Endpoint, conversation,
            conversation_updated: "conversation.updated"
          )

          {:ok, conversation}

        {:error, changeset} ->
          {:error, Resolvers.format_changeset_errors(changeset.errors)}
      end
    else
      nil -> {:error, "conversation not found"}
    end
  end

  def update_conversation_name(_, _, _) do
    {:error, "unauthorized"}
  end

  def create_message(_, args = %{conversation_id: id}, %{context: %{authenticated?: true}}) do
    body = Map.get(args, :body)
    url = Map.get(args, :attachment_url)
    url_type = Map.get(args, :url_type)
    direction = "outbound"
    status = "sending"
    conversation = Repo.get!(Conversation, id)

    if body in [nil, ""] and !url do
      {:error, "must include a body or attachment url"}
    else
      attachment_attrs = %{
        conversation_id: id,
        attachment_url: url,
        direction: direction,
        status: status,
        type: url_type
      }

      attachment_result =
        Repo.transaction(fn ->
          with true <- url not in [nil, ""],
               {:ok, message} <- Conversations.create_message(attachment_attrs),
               {:ok, %{"id" => id}} <- send_attachment(conversation, url),
               {:ok, message} <- Conversations.update_message(message, %{external_id: id}) do
            message
          else
            _ -> :error
          end
        end)

      text_attrs = %{
        conversation_id: id,
        body: body,
        direction: direction,
        status: status,
        type: "text"
      }

      text_result =
        Repo.transaction(fn ->
          with true <- body not in [nil, ""],
               {:ok, message} <- Conversations.create_message(text_attrs),
               {:ok, %{"id" => id}} <- send_text(conversation, body),
               {:ok, message} <- Conversations.update_message(message, %{external_id: id}) do
            message
          else
            _ -> :error
          end
        end)

      Conversations.update_conversation(conversation, %{unread_at: nil})

      {:ok, for({:ok, m} <- [text_result, attachment_result], m != :error, do: m)}
    end
  end

  def create_message(_, _, _) do
    {:error, "unauthorized"}
  end

  # Telnyx functions

  defp send_text(conversation = %Conversation{}, body) when is_binary(body) do
    attrs = %{
      from: @from_number,
      to: conversation.number,
      text: body,
      webhook_url: @status_url
    }

    Telnyx.Messages.create(attrs, @telnyx_api_key)
  end

  defp send_attachment(conversation = %Conversation{}, url) when is_binary(url) do
    attrs = %{
      from: @from_number,
      to: conversation.number,
      media_urls: [url],
      webhook_url: @status_url
    }

    Telnyx.Messages.create(attrs, @telnyx_api_key)
  end

  # Batch resolvers

  def batch_most_recent_messages(_, conversation_ids) do
    most_recent_messages =
      from(m in Message,
        where: m.conversation_id in ^conversation_ids,
        group_by: m.conversation_id,
        select: %{inserted_at: max(m.inserted_at), conversation_id: m.conversation_id},
        distinct: m.conversation_id
      )

    query =
      from(most_recent in subquery(most_recent_messages),
        join: m in Message,
        on:
          m.conversation_id == most_recent.conversation_id and
            m.inserted_at == most_recent.inserted_at,
        select: m
      )

    [query: query]
    |> Conversations.list_messages()
    |> Map.new(&{&1.conversation_id, &1})
  end

  def batch_messages(_, conversation_ids) do
    query =
      from(m in Message,
        where: m.conversation_id in ^conversation_ids,
        order_by: [asc: m.inserted_at]
      )

    [query: query]
    |> Conversations.list_messages()
    |> Enum.group_by(fn %{conversation_id: id} -> id end)
  end
end
