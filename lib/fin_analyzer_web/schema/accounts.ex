defmodule FinAnalyzerWeb.Schema.Accounts do
  alias FinAnalyzerWeb.Resolvers
  use Absinthe.Schema.Notation

  object :user do
    field :email, :string
    field :confirmed_at, :naive_datetime

    field :transactions, list_of(:transaction) do
      resolve(&Resolvers.Transactions.list_user_transactions/2)
    end
  end
end
