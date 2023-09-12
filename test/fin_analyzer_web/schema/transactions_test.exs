defmodule FinAnalyzerWeb.TransactionsTest do
  use FinAnalyzerWeb.ConnCase

  import FinAnalyzer.TransactionsFixtures

  describe "transactions api" do
    setup :register_and_log_in_user

    test "uploads transactions via input file", %{conn: conn} do
      transactions = %Plug.Upload{
        path: "test/assets/transactions.csv",
        filename: "transactions.csv"
      }

      query = """
      mutation ($transactions_csv: Upload!) {
      	uploadTransactions(transactions: $transactions_csv)
      }
      """

      conn =
        post(conn, "/api",
          query: query,
          variables: %{transactions_csv: "transactions"},
          transactions: transactions
        )

      assert json_response(conn, 200) == %{
               "data" => %{"uploadTransactions" => "sucessfully uploaded 3 transactions"}
             }

      query = """
        query {
          transactions(first:4) {
            edges {
              node {
                date
        				amount
                description
        				category
              }
            }
          }
        }
      """

      conn = post(conn, "/api", query)

      assert json_response(conn, 200) ==
               %{
                 "data" => %{
                   "transactions" => %{
                     "edges" => [
                       %{
                         "node" => %{
                           "amount" => 4500,
                           "category" => "ENTERTAINMENT",
                           "date" => "2019-03-12",
                           "description" => "Movie ticket"
                         }
                       },
                       %{
                         "node" => %{
                           "amount" => 120_000,
                           "category" => "RENT",
                           "date" => "2019-02-03",
                           "description" => "February Rent"
                         }
                       },
                       %{
                         "node" => %{
                           "amount" => 5000,
                           "category" => "GROCERIES",
                           "date" => "2019-01-01",
                           "description" => "Bread and milk"
                         }
                       }
                     ]
                   }
                 }
               }
    end

    test "categorizes a transaction", %{user: user, conn: conn} do
      tx = transaction_fixture(user, %{amount: 100, date: ~D[2021-05-01], category: :others})

      query = """
      mutation($id: ID!, $category: TransactionCategory!) {
      	categorizeTransaction(
      		id: $id,
      		category: $category
      	) {
      		id
      		category
      	}
      }
      """

      variables = %{id: tx.id, category: "SPORTS"}

      conn = post(conn, "/api", %{query: query, variables: variables})

      assert json_response(conn, 200) ==
               %{
                 "data" => %{
                   "categorizeTransaction" => %{
                     "category" => "SPORTS",
                     "id" => "#{tx.id}"
                   }
                 }
               }
    end

    test "lists user transactions", %{user: user, conn: conn} do
      transaction_fixture(user, %{amount: 100, date: ~D[2021-05-01], category: :sports})
      transaction_fixture(user, %{amount: 150, date: ~D[2022-07-01], category: :groceries})
      transaction_fixture(user, %{amount: 250, date: ~D[2022-09-03], category: :groceries})
      transaction_fixture(user, %{amount: 100, date: ~D[2023-03-01], category: :education})
      transaction_fixture(user, %{amount: 200, date: ~D[2023-03-02], category: :education})
      transaction_fixture(user, %{amount: 300, date: ~D[2023-08-02], category: :education})

      query = """
        query {
          transactions(first:4) {
            edges {
              node {
                date
        				amount
        				category
              }
            }
          }
        }
      """

      conn = post(conn, "/api", query)

      assert json_response(conn, 200) ==
               %{
                 "data" => %{
                   "transactions" => %{
                     "edges" => [
                       %{
                         "node" => %{
                           "amount" => 300,
                           "category" => "EDUCATION",
                           "date" => "2023-08-02"
                         }
                       },
                       %{
                         "node" => %{
                           "amount" => 200,
                           "category" => "EDUCATION",
                           "date" => "2023-03-02"
                         }
                       },
                       %{
                         "node" => %{
                           "amount" => 100,
                           "category" => "EDUCATION",
                           "date" => "2023-03-01"
                         }
                       },
                       %{
                         "node" => %{
                           "amount" => 250,
                           "category" => "GROCERIES",
                           "date" => "2022-09-03"
                         }
                       }
                     ]
                   }
                 }
               }
    end
  end
end
