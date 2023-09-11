defmodule FinAnalyzerWeb.Schema.Analysis do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  object :monthly_average do
    field :month, :string
    field :average, :float
  end

  connection(node_type: :monthly_average)

  object(:category_expenses) do
    field :category, :transaction_category
    field :transaction_count, :integer
    field :total_spent, :integer
    field :transactions, list_of(:transaction)
  end

  connection(node_type: :category_expenses)
end
