defmodule FinAnalyzerWeb.Resolvers.Transactions do
  alias FinAnalyzer.Transactions

  def list_transactions(_args, _info) do
    {:ok, Transactions.list_transactions()}
  end

  def upload_transactions(args, _info) do
    num_imported =
      args.transactions.path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Enum.reduce(0, fn
        {:ok, parsed_fields}, acc ->
          amount = parsed_fields["amount"] |> String.replace(".", "")
          date = parsed_fields["date"]
          description = parsed_fields["description"]
          category = parsed_fields["category"]

          case Transactions.create_transaction(%{
                 amount: amount,
                 date: date,
                 description: description,
                 category: category
               }) do
            {:ok, _transaction} ->
              acc + 1

            {:error, message} ->
              IO.puts(message)
              acc
          end

        {:error, message}, acc ->
          IO.puts(message)
          acc
      end)

    {:ok, "sucessfully uploaded #{num_imported} transactions"}
  end
end
