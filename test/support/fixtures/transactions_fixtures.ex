defmodule FinAnalyzer.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FinAnalyzer.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(user, attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        date: ~D[2023-09-03],
        description: "some description",
        category: :groceries,
        amount: 42,
        user_id: user.id
      })
      |> FinAnalyzer.Transactions.create_transaction()

    transaction
  end
end
