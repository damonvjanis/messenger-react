defmodule BackendWeb.MessageController do
  use BackendWeb, :controller

  alias Backend.Conversations
  alias Backend.Conversations.Message
  alias BackendWeb.Endpoint
  alias Absinthe.Subscription

  require Logger

  def inbound(conn, %{"data" => %{"payload" => payload}}) do
    Task.start(fn -> do_inbound(payload) end)

    resp(conn, 200, "")
  end

  defp do_inbound(%{"from" => from, "id" => id, "media" => media, "text" => text}) do
    data = %{
      number: from["phone_number"],
      unread_at: NaiveDateTime.utc_now()
    }

    with {:ok, conversation} <- Conversations.upsert_conversation(data) do
      for %{"content_type" => content_type, "url" => url} <- media do
        Conversations.create_message(
          %{
            direction: "inbound",
            status: "received",
            type: file_type(content_type),
            conversation_id: conversation.id,
            external_id: id,
            # Links expire after 30 days, need to move to perm bucket
            attachment_url: url
          },
          preloads: [:conversation]
        )
        |> case do
          {:ok, message} ->
            Subscription.publish(Endpoint, message, message_added: "message.added")

          {:error, changeset} ->
            Logger.error("Inbound attachment failed: #{inspect(changeset)}")
        end
      end

      if text != "" do
        Conversations.create_message(
          %{
            direction: "inbound",
            status: "received",
            type: "text",
            body: text,
            conversation_id: conversation.id,
            external_id: id
          },
          preloads: [:conversation]
        )
        |> case do
          {:ok, message} ->
            Subscription.publish(Endpoint, message, message_added: "message.added")

          {:error, changeset} ->
            Logger.error("Inbound text failed: #{inspect(changeset)}")
        end
      end
    else
      {:error, error} ->
        Logger.error(
          "Inbound failure: from #{from["phone_number"]} with body '#{text}' and error #{
            inspect(error)
          }"
        )
    end
  end

  defp file_type("image" <> _), do: "image"
  defp file_type(_), do: "file"

  def status(conn, %{"data" => params}) do
    Task.start(fn -> do_status(params) end)

    resp(conn, 200, "")
  end

  defp do_status(%{"event_type" => "message.sent", "payload" => %{"id" => id}}) do
    with message = %Message{} <- Conversations.get_message_by_external_id(id) do
      Conversations.update_message(message, %{status: "sent"})
    end
  end

  defp do_status(%{"event_type" => "message.finalized", "payload" => %{"id" => id}}) do
    with message = %Message{} <- Conversations.get_message_by_external_id(id),
         {:ok, message} <-
           Conversations.update_message(message, %{status: "delivered"}, preloads: [:conversation]) do
      Subscription.publish(Endpoint, message, message_updated: "message.updated")
    end
  end

  defp do_status(_) do
    nil
  end
end
