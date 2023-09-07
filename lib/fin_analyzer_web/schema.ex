defmodule FinAnalyzerWeb.Schema do
  use Absinthe.Schema
  import_types(FinAnalyzerWeb.Schema.Transactions)
  import_types(FinAnalyzerWeb.Schema.Analysis)
  import_types(Absinthe.Plug.Types)

  alias FinAnalyzerWeb.Middleware.ErrorHandler
  alias FinAnalyzerWeb.Middleware.SafeResolution
  alias FinAnalyzerWeb.Resolvers

  query do
    field :transaction, :transaction do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Transactions.get_transaction/2)
    end

    field :transactions, list_of(:transaction) do
      resolve(&Resolvers.Transactions.list_transactions/2)
    end

    @desc "Average amount spent for all months during which at least one transaction has occurred"
    field :average_monthly_spending, list_of(:monthly_average) do
      resolve(&Resolvers.Analysis.average_monthly_spending/2)
    end
  end

  mutation do
    field :upload_transactions, :string do
      arg(:transactions, non_null(:upload))
      resolve(&Resolvers.Transactions.upload_transactions/2)
    end

    field :categorize_transaction, :transaction do
      arg(:id, non_null(:id))
      arg(:category, non_null(:transaction_category))
      resolve(&Resolvers.Transactions.categorize_transaction/2)
    end
  end

  def middleware(middleware, _field, %{identifier: type}) when type in [:query, :mutation] do
    SafeResolution.apply(middleware) ++ [ErrorHandler]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end
