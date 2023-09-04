defmodule FinAnalyzer.Repo do
  use Ecto.Repo,
    otp_app: :fin_analyzer,
    adapter: Ecto.Adapters.Postgres
end
