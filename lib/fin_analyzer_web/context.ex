defmodule FinAnalyzerWeb.Context do
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]
    Absinthe.Plug.put_options(conn, context: %{current_user: user})
  end
end
