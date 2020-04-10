defmodule Backend.Conversations do
  import Ecto.Query, warn: false

  alias Backend.Repo
  alias Backend.Conversations.Conversation
  alias Backend.Conversations.Message

  @default_region "US"
  @default_prefix "+1"

  def list_conversations(opts \\ []) do
    query = Keyword.get(opts, :query, nil)
    preloads = Keyword.get(opts, :preloads, [])

    (query || Conversation)
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  def get_conversation_by_id(id, opts \\ []) do
    preloads = Keyword.get(opts, :preloads, [])

    Conversation
    |> Repo.get(id)
    |> Repo.preload(preloads)
  end

  @doc "Input should already in valid e164 format"
  def get_conversation_by_number(@default_prefix <> _ = number) do
    {:ok, Repo.get_by(Conversation, number: number)}
  end

  def get_conversation_by_number(number) do
    {:error, "number #{inspect(number)} is not a valid #{@default_region} number"}
  end

  def create_conversation(attrs = %{}, opts \\ []) do
    changeset = Keyword.get(opts, :changeset, &Conversation.changeset/2)

    %Conversation{}
    |> changeset.(attrs)
    |> Repo.insert()
  end

  def update_conversation(conversation = %Conversation{}, attrs = %{}, opts \\ []) do
    changeset = Keyword.get(opts, :changeset, &Conversation.changeset/2)

    conversation
    |> changeset.(attrs)
    |> Repo.update()
  end

  def upsert_conversation(attrs = %{}, opts \\ []) do
    changeset = Keyword.get(opts, :changeset, &Conversation.changeset/2)
    on_conflict = Keyword.get(opts, :on_conflict, {:replace, [:number]})
    conflict_target = Keyword.get(opts, :on_conflict, :number)

    %Conversation{}
    |> changeset.(attrs)
    |> Repo.insert(returning: true, on_conflict: on_conflict, conflict_target: conflict_target)
  end

  def delete_conversation(conversation = %Conversation{}) do
    Repo.delete(conversation)
  end

  def change_conversation(conversation = %Conversation{}) do
    Conversation.changeset(conversation, %{})
  end

  def list_messages(opts \\ []) do
    query = Keyword.get(opts, :query, nil)
    preloads = Keyword.get(opts, :preloads, [])

    (query || Message)
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  def get_message(id) do
    Message
    |> Repo.get(id)
  end

  def get_message_by_external_id(id) do
    Repo.get_by(Message, external_id: id)
  end

  def create_message(attrs \\ %{}, opts \\ []) do
    preloads = Keyword.get(opts, :preloads, [])

    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} -> {:ok, Repo.preload(message, preloads)}
      error -> error
    end
  end

  def update_message(%Message{} = message, attrs, opts \\ []) do
    preloads = Keyword.get(opts, :preloads, [])

    message
    |> Message.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, message} -> {:ok, Repo.preload(message, preloads)}
      error -> error
    end
  end

  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end

  def format_number(number) when is_binary(number) do
    with {:ok, parsed} <- ExPhoneNumber.parse(number, @default_region) do
      {:ok, ExPhoneNumber.format(parsed, :e164)}
    end
  end

  def format_number(_) do
    {:error, "invalid number format, not a string"}
  end
end
