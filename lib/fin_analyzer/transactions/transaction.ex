defmodule FinAnalyzer.Transactions.Transaction do
  use FinAnalyzer.Schema

  alias FinAnalyzer.Accounts.User

  schema "transactions" do
    field :amount, :integer
    field :date, :date
    field :description, :string

    field :category, Ecto.Enum,
      values: [
        :groceries,
        :rent,
        :entertainment,
        :transportation,
        :shopping,
        :restaurants,
        :education,
        :sports,
        :health,
        :others
      ]

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :amount, :description, :category, :user_id])
    |> validate_required([:date, :amount, :category, :user_id])
  end
end
