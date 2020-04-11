defmodule Backend.Repo.Migrations.AddUnreadAtToConversations do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add :unread_at, :naive_datetime_usec
    end

    create index(:conversations, [:unread_at])
  end
end
