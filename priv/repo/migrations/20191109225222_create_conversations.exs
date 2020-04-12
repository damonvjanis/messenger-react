defmodule Backend.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :name, :string
      add :number, :string
      add :unread_at, :naive_datetime_usec

      timestamps()
    end

    create index(:conversations, [:unread_at])
    create unique_index(:conversations, [:number])
  end
end
