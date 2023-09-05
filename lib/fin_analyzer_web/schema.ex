defmodule FinAnalyzerWeb.Schema do
  use Absinthe.Schema
  import_types(FinAnalyzerWeb.Schema.Transactions)

  alias FinAnalyzerWeb.Resolvers

  query do
    field :transactions, list_of(:transaction) do
      resolve(&Resolvers.Transactions.list_transactions/2)
    end
  end
end
