defmodule Backend.Conversations.Conversation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Conversations
  alias Backend.Conversations.Message

  @timestamps_opts [type: :naive_datetime_usec]

  schema "conversations" do
    field :name, :string
    field :number, :string
    field :most_recent_message, :map, virtual: true

    timestamps()

    has_many :messages, Message
  end

  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:name, :number])
    |> validate_required([:number])
    |> format_number()
    |> unique_constraint(:number)
  end

  defp format_number(changeset = %{changes: %{number: number}}) do
    case Conversations.format_number(number) do
      {:ok, formatted} -> put_change(changeset, :number, formatted)
      {:error, error} -> put_change(changeset, :number, error)
    end
  end

  defp format_number(changeset) do
    changeset
  end
end
