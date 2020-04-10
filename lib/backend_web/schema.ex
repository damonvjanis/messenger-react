defmodule BackendWeb.Schema do
  use Absinthe.Schema

  alias BackendWeb.Resolvers.ConversationResolver
  alias BackendWeb.Resolvers.LoginResolver

  import_types(BackendWeb.Types)
  import_types(Absinthe.Type.Custom)

  query do
    field :is_logged_in, :is_logged_in do
      resolve(&LoginResolver.is_logged_in/2)
    end

    field :get_cloudinary_url, :get_cloudinary_url do
      resolve(&ConversationResolver.get_cloudinary_url/2)
    end

    # field :get_conversations, list_of(:conversation_batched_messages_and_most_recent) do
    #   resolve(&ConversationResolver.get_conversations/2)
    # end

    field :get_conversations_ordered, :conversation_list do
      arg(:search, :string)
      arg(:cursor, :id)

      resolve(&ConversationResolver.get_conversations_ordered/2)
    end

    field :get_conversation_by_id, :conversation do
      arg(:id, :id)

      resolve(&ConversationResolver.get_conversation_by_id/2)
    end

    field :get_conversation_by_number, :conversation_batched_messages_and_most_recent do
      arg(:number, non_null(:string))

      resolve(&ConversationResolver.get_conversation_by_number/2)
    end
  end

  mutation do
    field :login, :login do
      arg(:code, non_null(:string))

      resolve(&LoginResolver.login/2)
    end

    field :create_conversation, type: :conversation do
      arg(:number, non_null(:string))
      arg(:name, :string)

      resolve(&ConversationResolver.create_conversation/3)
    end

    field :create_conversation_and_message, type: :conversation do
      arg(:number, non_null(:string))
      arg(:name, :string)
      arg(:body, :string)
      arg(:attachment_url, :string)
      arg(:url_type, :string)

      resolve(&ConversationResolver.create_conversation_and_message/3)
    end

    field :update_conversation_name, type: :conversation do
      arg(:id, non_null(:id))
      arg(:name, :string)

      resolve(&ConversationResolver.update_conversation_name/3)
    end

    field :create_message, type: list_of(:message) do
      arg(:conversation_id, non_null(:id))
      arg(:body, :string)
      arg(:attachment_url, :string)
      arg(:url_type, :string)

      resolve(&ConversationResolver.create_message/3)
    end
  end

  subscription do
    field :message_added, :message do
      config(fn _, _ ->
        {:ok, topic: "message.added"}
      end)
    end

    field :message_updated, :message do
      config(fn _, _ ->
        {:ok, topic: "message.updated"}
      end)
    end

    field :conversation_updated, :conversation do
      config(fn _, _ ->
        {:ok, topic: "conversation.updated"}
      end)
    end
  end
end
