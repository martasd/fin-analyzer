defmodule FinAnalyzerWeb.Router do
  use FinAnalyzerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug FinAnalyzerWeb.Context
  end

  # Other scopes may use custom stacks.
  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: FinAnalyzerWeb.Schema
    forward "/", Absinthe.Plug, schema: FinAnalyzerWeb.Schema
  end
end
