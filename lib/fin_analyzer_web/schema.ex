defmodule FinAnalyzerWeb.Schema do
  use Absinthe.Schema
  import_types(FinAnalyzerWeb.Schema.Transactions)
  import_types(Absinthe.Plug.Types)

  alias FinAnalyzerWeb.Resolvers

  query do
    field :transactions, list_of(:transaction) do
      resolve(&Resolvers.Transactions.list_transactions/2)
    end
  end

  mutation do
    field :upload_transactions, :string do
      arg(:transactions, non_null(:upload))
      resolve(&Resolvers.Transactions.upload_transactions/2)
    end

    field :categorize_transaction, :transaction do
      arg(:transaction_id, non_null(:id))
      arg(:category, non_null(:transaction_category))
      resolve(&Resolvers.Transactions.categorize_transaction/2)
    end
  end
end
