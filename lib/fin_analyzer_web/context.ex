defmodule FinAnalyzerWeb.Context do
  @behaviour Plug

  alias FinAnalyzer.Accounts
  alias Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header.
  """
  def build_context(conn) do
    with [string_token] <- Conn.get_req_header(conn, "authorization"),
         {:ok, token} <- Base.url_decode64(string_token, padding: false),
         user <- Accounts.get_user_by_session_token(token) do
      %{current_user: user}
    else
      _ -> %{}
    end
  end
end
