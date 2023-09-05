defmodule FinAnalyzerWeb.Resolvers.Transactions do
  def list_transactions(_args, _info) do
    {:ok, FinAnalyzer.Transactions.list_transactions()}
  end
end
