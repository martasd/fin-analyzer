defmodule FinAnalyzerWeb.Schema do
  use Absinthe.Schema
  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)
  import_types(FinAnalyzerWeb.Schema.Accounts)
  import_types(FinAnalyzerWeb.Schema.Analysis)
  import_types(FinAnalyzerWeb.Schema.Transactions)

  alias FinAnalyzerWeb.Middleware.ErrorHandler
  alias FinAnalyzerWeb.Middleware.SafeResolution
  alias FinAnalyzerWeb.Resolvers

  query do
    field :me, :user do
      resolve(&Resolvers.Accounts.get_current_user/2)
    end

    field :transaction, :transaction do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Transactions.get_transaction/2)
    end

    @desc "Average amount spent for all months during which at least one transaction has occurred"
    field :average_monthly_spending, list_of(:monthly_average) do
      resolve(&Resolvers.Analysis.average_monthly_spending/2)
    end

    @desc "Expenses by category"
    field :expenses_by_category, list_of(:category_expenses) do
      resolve(&Resolvers.Analysis.expenses_by_category/2)
    end

    @desc "Largest expenses ordered by amount"
    field :largest_expenses, list_of(:transaction) do
      resolve(&Resolvers.Analysis.largest_expenses/2)
    end
  end

  mutation do
    @desc "Import transactions via CSV file"
    field :upload_transactions, :string do
      arg(:transactions, non_null(:upload))
      resolve(&Resolvers.Transactions.upload_transactions/2)
    end

    @desc "Categorize a transaction"
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
