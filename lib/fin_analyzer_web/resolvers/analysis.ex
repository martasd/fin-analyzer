defmodule FinAnalyzerWeb.Resolvers.Analysis do
  alias Absinthe.Relay.Connection
  alias FinAnalyzer.Accounts
  alias FinAnalyzer.Transactions

  @doc """
  Calculate the average amount spent for each month, which had at least one transaction.
  """
  def average_monthly_spending(args, info) do
    with {:ok, user} <- Accounts.get_current_user(info) do
      monthly_stats =
        Transactions.list_transactions(user, args)
        |> Enum.reduce(%{}, fn tx, monthly_stats ->
          month = "#{tx.date.year}-#{tx.date.month}"

          case Map.get(monthly_stats, month) do
            nil ->
              Map.put(monthly_stats, month, {tx.amount, 1})

            {sum, tx_count} ->
              Map.replace(monthly_stats, month, {sum + tx.amount, tx_count + 1})
          end
        end)

      monthly_averages =
        for {month, {sum, tx_count}} <- monthly_stats,
            do: %{month: month, average: sum / tx_count}

      Connection.from_list(monthly_averages, args)
    end
  end

  @doc """
  Get the list of expenses for each category along with its total.
  """
  def expenses_by_category(args, info) do
    with {:ok, user} <- Accounts.get_current_user(info) do
      category_stats =
        Transactions.list_transactions(user, args)
        |> Enum.reduce(%{}, fn tx, category_stats ->
          category = tx.category

          case Map.get(category_stats, category) do
            nil ->
              Map.put(category_stats, category, {1, tx.amount, [tx]})

            {tx_count, tx_sum, txs} ->
              Map.replace(
                category_stats,
                category,
                {tx_count + 1, tx_sum + tx.amount, [tx | txs]}
              )
          end
        end)

      expenses_by_category =
        for {category, {tx_count, tx_sum, txs}} <- category_stats,
            do: %{
              category: category,
              transaction_count: tx_count,
              total_spent: tx_sum,
              transactions: txs
            }

      Connection.from_list(expenses_by_category, args)
    end
  end

  @doc """
  Get the user's expenses ordered by their amount.
  """
  def largest_expenses(args, info) do
    with {:ok, user} <- Accounts.get_current_user(info) do
      Transactions.list_largest_transactions(user)
      |> Connection.from_list(args)
    end
  end
end
