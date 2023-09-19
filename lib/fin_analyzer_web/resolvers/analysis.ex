defmodule FinAnalyzerWeb.Resolvers.Analysis do
  alias Absinthe.Relay.Connection
  alias FinAnalyzer.Accounts
  alias FinAnalyzer.Accounts.User
  alias FinAnalyzer.Transactions

  @doc """
  Calculate the average amount spent for each month using SQL.
  """
  def average_monthly_spending_sql(_args, info) do
    with {:ok, %User{id: id}} <- Accounts.get_current_user(info),
         {:ok, user_id} <- Ecto.UUID.dump(id),
         {:ok, %{rows: rows}} <- Transactions.average_monthly_spending(user_id) do
      {:ok,
       Enum.map(rows, fn row ->
         [year, month, average] = row
         month = "#{year}-#{month}"
         %{month: month, average: Decimal.to_float(average)}
       end)}
    end
  end

  @doc """
  Calculate the average amount spent for each month using Elixir.
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

      {:ok, monthly_averages}
    end
  end

  @doc """
  Get transaction statistics for a given category.
  """
  def category_stats(%{category: category}, info) do
    with {:ok, %User{id: user_id}} <- Accounts.get_current_user(info) do
      {:ok,
       %{
         total_spent: Transactions.total_spent_for_category(user_id, category),
         transaction_count: Transactions.transaction_count_for_category(user_id, category)
       }}
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
              Map.put(category_stats, category, {1, tx.amount})

            {tx_count, tx_sum} ->
              Map.replace(
                category_stats,
                category,
                {tx_count + 1, tx_sum + tx.amount}
              )
          end
        end)

      expenses_by_category =
        for {category, {tx_count, tx_sum}} <- category_stats,
            do: %{
              category: category,
              transaction_count: tx_count,
              total_spent: tx_sum
            }

      {:ok, expenses_by_category}
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
