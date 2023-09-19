defmodule FinAnalyzer.TransactionsTest do
  use FinAnalyzer.DataCase

  alias FinAnalyzer.Transactions

  import FinAnalyzer.AccountsFixtures

  setup do
    user = user_fixture()
    {:ok, user: user}
  end

  describe "transactions" do
    alias FinAnalyzer.Transactions.Transaction

    import FinAnalyzer.TransactionsFixtures

    @invalid_attrs %{date: nil, description: nil, category: nil, amount: nil}

    test "list_transactions/0 returns all transactions", %{user: user} do
      transaction = transaction_fixture(user)
      assert Transactions.list_transactions(user) == [transaction]
    end

    test "get_transaction/1 returns the transaction with given id", %{user: user} do
      transaction = transaction_fixture(user)
      assert Transactions.get_transaction(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction", %{user: user} do
      valid_attrs = %{
        date: ~D[2023-09-03],
        description: "some description",
        category: :groceries,
        amount: 42,
        user_id: user.id
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.date == ~D[2023-09-03]
      assert transaction.description == "some description"
      assert transaction.category == :groceries
      assert transaction.amount == 42
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction", %{user: user} do
      transaction = transaction_fixture(user)

      update_attrs = %{
        date: ~D[2023-09-04],
        description: "some updated description",
        category: :rent,
        amount: 43
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.date == ~D[2023-09-04]
      assert transaction.description == "some updated description"
      assert transaction.category == :rent
      assert transaction.amount == 43
    end

    test "update_transaction/2 with invalid data returns error changeset", %{user: user} do
      transaction = transaction_fixture(user)

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, @invalid_attrs)

      assert transaction == Transactions.get_transaction(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction", %{user: user} do
      transaction = transaction_fixture(user)
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert nil == Transactions.get_transaction(transaction.id)
    end

    test "change_transaction/1 returns a transaction changeset", %{user: user} do
      transaction = transaction_fixture(user)
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end
  end
end
