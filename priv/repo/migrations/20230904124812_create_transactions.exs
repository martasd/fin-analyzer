defmodule FinAnalyzer.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :amount, :integer
      add :description, :string
      add :category, :string

      timestamps()
    end
  end
end
