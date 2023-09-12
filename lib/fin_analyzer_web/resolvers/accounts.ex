defmodule FinAnalyzerWeb.Resolvers.Accounts do
  alias FinAnalyzer.Accounts
  alias FinAnalyzer.Accounts.User
  alias FinAnalyzer.Accounts.UserToken
  alias FinAnalyzer.Repo

  def register_user(args, _info) do
    Accounts.register_user(args)
  end

  def get_user_token(%{email: email, password: password}, _info) do
    with %User{} = user <- Accounts.get_user_by_email_and_password(email, password) do
      IO.inspect(user)

      %UserToken{token: binary_token, context: context} =
        case(Accounts.UserToken.user_and_contexts_query(user, ["session"]) |> Repo.one()) do
          nil ->
            Accounts.generate_and_get_user_session_token(user)

          %UserToken{} = token ->
            token
        end

      token = Base.url_encode64(binary_token, padding: false)

      {:ok, %{token: token, context: context, user: user}}
    else
      _ -> {:error, :invalid_email_or_password}
    end
  end

  def delete_user_token(_args, info) do
    with {:ok, user} <- Accounts.get_current_user(info),
         %UserToken{token: token} <-
           UserToken.user_and_contexts_query(user, ["session"]) |> Repo.one(),
         :ok <- Accounts.delete_user_session_token(token) do
      {:ok, "User #{user.email} has been logged out."}
    else
      error -> error
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
