defmodule FinAnalyzerWeb.Resolvers.Analysis do
  import Ecto.Query, only: [order_by: 2]

  alias FinAnalyzer.Transactions
  alias FinAnalyzer.Transactions.Transaction
  alias FinAnalyzer.Repo

  @doc """
  Calculate the average amount spent for each month, which had at least one transaction.
  """
  def average_monthly_spending(_args, _info) do
    monthly_stats =
      Transactions.list_transactions()
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
      for {month, {sum, tx_count}} <- monthly_stats, do: %{month: month, average: sum / tx_count}

    {:ok, monthly_averages}
  end

  @doc """
  Get the user's expenses ordered by their amount.
  """
  def largest_expenses(_args, _info) do
    {:ok,
     Transaction
     |> order_by(desc: :amount, desc: :date)
     |> Repo.all()}
  end
end
