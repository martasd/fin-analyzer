defmodule FinAnalyzerWeb.Resolvers.Analysis do
  alias FinAnalyzer.Transactions

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

    # For each year-month divide total by count
    monthly_averages =
      for {month, {sum, tx_count}} <- monthly_stats, do: %{month: month, average: sum / tx_count}

    {:ok, monthly_averages}
  end
end
