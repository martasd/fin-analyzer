defmodule FinAnalyzerWeb.Resolvers.Accounts do
  alias FinAnalyzer.Accounts

  def get_current_user(_args, info) do
    Accounts.get_current_user(info)
  end
end
