defmodule FinAnalyzerWeb.Resolvers.Transactions do
  alias Absinthe.Relay.Connection
  alias FinAnalyzer.Accounts
  alias FinAnalyzer.Transactions

  require Logger

  def get_transaction(%{id: id}) do
    with tx <- Transactions.get_transaction!(id) do
      {:ok, tx}
    end
  end

  def get_user_transaction(%{id: id}, info) do
    with {:ok, user} <- Accounts.get_current_user(info),
         tx <- Transactions.get_user_transaction!(id, user.id) do
      {:ok, tx}
    end
  end

  def categorize_transaction(%{id: id, category: category}, info) do
    with {:ok, user} <- Accounts.get_current_user(info),
         tx <- Transactions.get_user_transaction!(id, user.id) do
      Transactions.update_transaction(tx, %{category: category})
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
      num_imported =
        args.transactions.path
        |> File.stream!()
        |> CSV.decode(headers: true)
        |> Enum.reduce(0, fn
          {:ok, parsed_fields}, acc ->
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
                acc + 1

              {:error, %Ecto.Changeset{changes: changes} = changeset} ->
                errors =
                  Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
                    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
                      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
                    end)
                  end)

                Logger.error(%{line: acc + 2, transaction: changes, errors: errors})
                acc
            end

          {:error, message}, acc ->
            Logger.error(message)
            acc
        end)

      {:ok, "sucessfully uploaded #{num_imported} transactions"}
    end
  end
end
