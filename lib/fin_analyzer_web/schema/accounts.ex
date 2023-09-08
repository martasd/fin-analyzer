defmodule FinAnalyzerWeb.Schema.Accounts do
  alias FinAnalyzerWeb.Resolvers
  use Absinthe.Schema.Notation

  object :user do
    field :email, :string
    field :confirmed_at, :naive_datetime
  end
end
