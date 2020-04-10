defmodule Backend.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text
      add :attachment_url, :text
      add :type, :string
      add :direction, :string
      add :status, :string, null: false, default: "sending"
      add :external_id, :string
      add :conversation_id, references(:conversations, on_delete: :delete_all)

      timestamps()
    end

    create index(:messages, [:conversation_id])
    create index(:messages, [:conversation_id, :inserted_at])
    create unique_index(:messages, :external_id)
  end
end
