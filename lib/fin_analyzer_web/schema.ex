defmodule FinAnalyzerWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)
  import_types(FinAnalyzerWeb.Schema.Accounts)
  import_types(FinAnalyzerWeb.Schema.Analysis)
  import_types(FinAnalyzerWeb.Schema.Transactions)

  alias FinAnalyzerWeb.Middleware.ErrorHandler
  alias FinAnalyzerWeb.Middleware.SafeResolution
  alias FinAnalyzerWeb.Resolvers

  node interface do
    resolve_type(fn
      %FinAnalyzer.Accounts.User{}, _ ->
        :user

      %FinAnalyzer.Transactions.Transaction{}, _ ->
        :transaction

      _, _ ->
        nil
    end)
  end

  query do
    node field do
      resolve(fn
        %{type: :user, id: id}, _ ->
          Resolvers.Accounts.get_user(id)

        %{type: :transaction, id: id}, _ ->
          Resolvers.Transactions.get_transaction(id)
      end)
    end

    @desc "Get current user details"
    field :me, :user do
      resolve(&Resolvers.Accounts.get_current_user/2)
    end

    @desc "Get transaction details"
    field :transaction, :transaction do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Transactions.get_user_transaction/2)
    end

    @desc "Get user transactions"
    connection field :transactions, node_type: :transaction do
      arg(:category, :transaction_category)
      resolve(&Resolvers.Transactions.list_user_transactions/2)
    end

    @desc "Average amount spent for all months during which at least one transaction has occurred"
    field :average_monthly_spending, list_of(:monthly_average) do
      arg(:category, :transaction_category)
      resolve(&Resolvers.Analysis.average_monthly_spending/2)
    end

    field :average_monthly_spending_sql, list_of(:monthly_average) do
      arg(:category, :transaction_category)
      resolve(&Resolvers.Analysis.average_monthly_spending_sql/2)
    end

    @desc "Transaction statistics for a given category"
    field :category_stats, list_of(:category_expenses) do
      arg(:category, :transaction_category)
      resolve(&Resolvers.Analysis.expenses_by_category/2)
    end

    field :category_stats_sql, :category_stats do
      arg(:category, non_null(:transaction_category))
      resolve(&Resolvers.Analysis.category_stats/2)
    end

    @desc "Largest expenses ordered by amount"
    connection field :largest_expenses, node_type: :transaction do
      resolve(&Resolvers.Analysis.largest_expenses/2)
    end
  end

  mutation do
    @desc "Register a new user"
    field :register_user, :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Accounts.register_user/2)
    end

    @desc "Log in by creating or fetching a user token"
    field :log_in, :user_token do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Accounts.get_user_token/2)
    end

    @desc "Log out by deleting the user token"
    field :log_out, :string do
      resolve(&Resolvers.Accounts.delete_user_token/2)
    end

    @desc "Import transactions via CSV file"
    field :upload_transactions, :upload_result do
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
