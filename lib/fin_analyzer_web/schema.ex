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

    field :get_user_token, :string do
      arg(:email, non_null(:string))
      resolve(&Resolvers.Accounts.get_user_token/2)
    end

    field :me, :user do
      resolve(&Resolvers.Accounts.get_current_user/2)
    end

    field :transaction, :transaction do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Transactions.get_user_transaction/2)
    end

    connection field :transactions, node_type: :transaction do
      arg(:category, :transaction_category)
      resolve(&Resolvers.Transactions.list_user_transactions/2)
    end

    @desc "Average amount spent for all months during which at least one transaction has occurred"
    connection field :average_monthly_spending, node_type: :monthly_average do
      arg(:category, :transaction_category)
      resolve(&Resolvers.Analysis.average_monthly_spending/2)
    end

    @desc "Expenses by category"
    connection field :expenses_by_category, node_type: :category_expenses do
      arg(:category, :transaction_category)
      resolve(&Resolvers.Analysis.expenses_by_category/2)
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
