defmodule FinAnalyzerWeb.Schema.Accounts do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :email, :string
    field :confirmed_at, :naive_datetime
  end

  object :user_token do
    field :token, :string
    field :context, :string
    field :user, :user
  end
end
