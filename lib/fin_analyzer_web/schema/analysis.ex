defmodule FinAnalyzerWeb.Schema.Analysis do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  object :monthly_average do
    field :month, :string
    field :average, :float
  end

  object(:category_stats) do
    field :total_spent, :integer
    field :transaction_count, :integer
  end

  object(:category_expenses) do
    field :category, :transaction_category
    field :total_spent, :integer
    field :transaction_count, :integer
  end
end
