defmodule FinAnalyzer.Repo.Migrations.AddUserToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
    end

    create index(:transactions, [:user_id])
  end
end
