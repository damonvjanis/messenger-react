defmodule Backend.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :name, :string
      add :number, :string

      timestamps()
    end

    create unique_index(:conversations, [:number])
  end
end
