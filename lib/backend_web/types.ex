defmodule BackendWeb.Types do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [batch: 3]

  alias BackendWeb.Resolvers

  @desc "Login success"
  object :login do
    field(:token, :string)
  end

  @desc "Logout success"
  object :logout do
    field(:logout_successful, :boolean)
  end

  @desc "Login state"
  object :is_logged_in do
    field(:is_logged_in, :boolean)
  end

  object :get_cloudinary_url do
    field(:url, :string)
  end

  object :conversation_list do
    field(:cursor, :string)
    field(:conversations, non_null(list_of(:conversation)))
  end

  @desc "Conversation without batching"
  object :conversation do
    field(:id, :id)
    field(:name, :string)
    field(:number, :string)
    field(:most_recent_message, :message)
    field(:messages, list_of(:message))
  end

  @desc "Conversation with batching"
  object :conversation_batched_messages_and_most_recent do
    field(:id, :id)
    field(:name, :string)
    field(:number, :string)

    field :messages, list_of(:message) do
      resolve(fn conversation, _, _ ->
        batch({Resolvers.ConversationResolver, :batch_messages}, conversation.id, fn results ->
          {:ok, Map.get(results, conversation.id)}
        end)
      end)
    end

    field :most_recent_message, :message do
      resolve(fn conversation, _, _ ->
        batch(
          {Resolvers.ConversationResolver, :batch_most_recent_messages},
          conversation.id,
          fn results ->
            {:ok, Map.get(results, conversation.id)}
          end
        )
      end)
    end
  end

  @desc "Message"
  object :message do
    field(:id, :id)
    field(:body, :string)
    field(:attachment_url, :string)
    field(:type, :string)
    field(:direction, :string)
    field(:status, :string)
    field(:inserted_at, :naive_datetime)

    field(:conversation, :conversation)
  end
end
