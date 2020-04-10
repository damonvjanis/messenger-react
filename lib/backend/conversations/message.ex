defmodule Backend.Conversations.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Conversations.Conversation

  @timestamps_opts [type: :naive_datetime_usec]

  schema "messages" do
    field :attachment_url, :string
    field :body, :string
    field :direction, :string
    field :type, :string
    field :status, :string, default: "sending"
    field :external_id, :string

    timestamps()

    belongs_to :conversation, Conversation
  end

  def changeset(message, attrs) do
    fields = [:conversation_id, :body, :attachment_url, :type, :direction, :status, :external_id]

    message
    |> cast(attrs, fields)
    |> validate_required([:conversation_id, :type, :direction])
    |> validate_inclusion(:type, ["text", "image", "file"])
    |> validate_inclusion(:direction, ["inbound", "outbound"])
    |> validate_inclusion(:status, ["sending", "sent", "failed", "delivered", "received"])
  end
end
