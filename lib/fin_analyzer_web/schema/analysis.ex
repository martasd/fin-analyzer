defmodule FinAnalyzerWeb.Schema.Analysis do
  use Absinthe.Schema.Notation

  @desc "An average expense per month"
  object :monthly_average do
    field :month, :string
    field :average, :float
  end
end
