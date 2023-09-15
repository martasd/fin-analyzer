defmodule FinAnalyzerWeb.Resolvers.Transactions do
  alias Absinthe.Relay.Connection
  alias FinAnalyzer.Accounts
  alias FinAnalyzer.Transactions
  alias FinAnalyzer.Transactions.Transaction

  require Logger

  def get_transaction(%{id: id}) do
    case Transactions.get_transaction(id) do
      nil ->
        {:error, :not_found}

      %Transaction{} = tx ->
        {:ok, tx}
    end
  end

  def get_user_transaction(%{id: id}, info) do
    with {:ok, user} <- Accounts.get_current_user(info) do
      case Transactions.get_user_transaction(id, user.id) do
        nil ->
          {:error, :not_found}

        %Transaction{} = tx ->
          {:ok, tx}
      end
    end
  end

  def categorize_transaction(%{id: id, category: category}, info) do
    with {:ok, user} <- Accounts.get_current_user(info) do
      case Transactions.get_user_transaction(id, user.id) do
        nil ->
          {:error, :not_found}

        %Transaction{} = tx ->
          Transactions.update_transaction(tx, %{category: category})
      end
    end
  end

  def list_user_transactions(args, info) do
    with {:ok, user} <- Accounts.get_current_user(info) do
      Transactions.list_transactions(user, args)
      |> Connection.from_list(args)
    end
  end

  def upload_transactions(args, info) do
    with {:ok, user} <- Accounts.get_current_user(info) do
      {num_imported, _, all_errors} =
        args.transactions.path
        |> File.stream!()
        |> CSV.decode(headers: true, validate_row_length: true)
        |> Enum.reduce({0, 2, %{}}, fn
          {:ok, parsed_fields}, {imported, row, errors} ->
            amount = parsed_fields["amount"]
            amount = if amount, do: String.replace(amount, ".", "")

            case Transactions.create_transaction(%{
                   amount: amount,
                   date: parsed_fields["date"],
                   description: parsed_fields["description"],
                   category: parsed_fields["category"],
                   user_id: user.id
                 }) do
              {:ok, _transaction} ->
                {imported + 1, row + 1, errors}

              {:error, %Ecto.Changeset{} = changeset} ->
                validation_errors =
                  changeset
                  |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
                  |> Enum.map(fn {k, v} -> String.capitalize("#{k} #{v}") end)

                {imported, row + 1, Map.put(errors, row, validation_errors)}
            end

          {:error, message}, {imported, row, errors} ->
            {imported, row + 1, Map.put(errors, row, message)}
        end)

      annotated_errors =
        for {row, field_validation_errors} <- all_errors,
            do: %{
              row: row,
              validation: field_validation_errors
            }

      {:ok,
       %{result: "sucessfully uploaded #{num_imported} transactions", errors: annotated_errors}}
    end
  end
end
