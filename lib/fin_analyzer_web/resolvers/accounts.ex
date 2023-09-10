defmodule FinAnalyzerWeb.Resolvers.Accounts do
  alias FinAnalyzer.Accounts
  alias FinAnalyzer.Accounts.UserToken
  alias FinAnalyzer.Repo

  def register_user(args, _info) do
    Accounts.register_user(args)
  end

  def get_user_token(%{email: email}, _info) do
    with user <- Accounts.get_user_by_email(email) do
      token =
        case(Accounts.UserToken.user_and_contexts_query(user, ["session"]) |> Repo.one()) do
          nil ->
            Accounts.generate_user_session_token(user)

          %UserToken{token: token} ->
            token
        end
        |> Base.url_encode64(padding: false)

      {:ok, token}
    end
  end

  def get_current_user(_args, info) do
    Accounts.get_current_user(info)
  end

  def get_user(id) do
    with user <- Accounts.get_user!(id) do
      {:ok, user}
    end
  end
end
