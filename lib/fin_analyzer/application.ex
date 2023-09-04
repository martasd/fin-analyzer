defmodule FinAnalyzer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FinAnalyzerWeb.Telemetry,
      # Start the Ecto repository
      FinAnalyzer.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: FinAnalyzer.PubSub},
      # Start Finch
      {Finch, name: FinAnalyzer.Finch},
      # Start the Endpoint (http/https)
      FinAnalyzerWeb.Endpoint
      # Start a worker by calling: FinAnalyzer.Worker.start_link(arg)
      # {FinAnalyzer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FinAnalyzer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FinAnalyzerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
