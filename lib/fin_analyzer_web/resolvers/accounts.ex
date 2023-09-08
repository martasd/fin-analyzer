defmodule FinAnalyzerWeb.Resolvers.Accounts do
  alias FinAnalyzer.Accounts

  def get_current_user(_args, info) do
    Accounts.get_current_user(info)
  end

  def get_user(id) do
    with user <- Accounts.get_user!(id) do
      {:ok, user}
    end
  end
end
