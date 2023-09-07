defmodule FinAnalyzerWeb.Schema.Analysis do
  use Absinthe.Schema.Notation

  object :monthly_average do
    field :month, :string
    field :average, :float
  end

  object :category_expenses do
    field :category, :transaction_category
    field :transaction_count, :integer
    field :total_spent, :integer
    field :transactions, list_of(:transaction)
  end
end
