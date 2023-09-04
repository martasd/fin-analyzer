defmodule FinAnalyzer.Transactions.Transaction do
  use FinAnalyzer.Schema

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

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :amount, :description, :category])
    |> validate_required([:date, :amount, :category])
  end
end
