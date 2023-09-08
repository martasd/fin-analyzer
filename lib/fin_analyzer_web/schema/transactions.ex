defmodule FinAnalyzerWeb.Schema.Transactions do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  enum :transaction_category do
    value(:groceries)
    value(:rent)
    value(:entertainment)
    value(:transportation)
    value(:shopping)
    value(:restaurants)
    value(:education)
    value(:sports)
    value(:health)
    value(:others)
  end

  object :transaction do
    field :id, :id
    field :amount, :integer
    field :date, :date
    field :description, :string
    field :category, :transaction_category
  end

  connection(node_type: :transaction)
end
