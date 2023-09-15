defmodule FinAnalyzer.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias FinAnalyzer.Repo

  alias FinAnalyzer.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions(user, filters)
      [%Transaction{}, ...]

  """
  def list_transactions(user, filters \\ %{}) do
    Transaction
    |> where(user_id: ^user.id)
    |> filter_by_category(filters[:category])
    |> order_by(desc: :date, desc: :amount)
    |> Repo.all()
  end

  defp filter_by_category(query, nil), do: query

  defp filter_by_category(query, category) do
    query |> where(category: ^category)
  end

  @doc """
  Returns the list of largest transactions.
  """
  def list_largest_transactions(user) do
    Transaction
    |> where(user_id: ^user.id)
    |> order_by(desc: :amount, desc: :date)
    |> Repo.all()
  end

  @doc """
  Gets a single transaction.

  Returns `nil` if the Transaction does not exist.

  ## Examples

      iex> get_transaction(123)
      %Transaction{}

      iex> get_transaction(456)
      nil

  """
  def get_transaction(id), do: Repo.get(Transaction, id)

  @doc """
  Gets a single transaction from user given a transaction id.

  Returns `nil` if the Transaction does not exist.
  """
  def get_user_transaction(id, user_id) do
    Transaction
    |> where(id: ^id, user_id: ^user_id)
    |> Repo.one()
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
