defmodule FinAnalyzerWeb.AnalysisTest do
  use FinAnalyzerWeb.ConnCase

  import FinAnalyzer.TransactionsFixtures

  describe "expense analysis api" do
    setup :register_and_log_in_user

    test "retrieves user's largest expenses ordered by amount and date", %{user: user, conn: conn} do
      transaction_fixture(user, %{amount: 100, date: ~D[2023-09-11]})
      transaction_fixture(user, %{amount: 200, date: ~D[2023-09-11]})
      transaction_fixture(user, %{amount: 100, date: ~D[2023-09-10]})

      query = """
        query {
          largestExpenses(first:3) {
            edges {
              node {
                amount
                date
              }
            }
          }
        }
      """

      conn = post(conn, "/api", query)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "largestExpenses" => %{
                   "edges" => [
                     %{"node" => %{"amount" => 200, "date" => "2023-09-11"}},
                     %{"node" => %{"amount" => 100, "date" => "2023-09-11"}},
                     %{"node" => %{"amount" => 100, "date" => "2023-09-10"}}
                   ]
                 }
               }
             }
    end

    test "calculates user's transaction stats for each category", %{user: user, conn: conn} do
      transaction_fixture(user, %{amount: 100, category: :rent})

      transaction_fixture(user, %{amount: 150, category: :groceries})
      transaction_fixture(user, %{amount: 250, category: :groceries})

      transaction_fixture(user, %{amount: 100, category: :education})
      transaction_fixture(user, %{amount: 200, category: :education})
      transaction_fixture(user, %{amount: 300, category: :education})

      query = """
        query {
        	expensesByCategory(first: 3) {
        		edges {
        			node {
        				category
        				transactionCount
        				totalSpent
        				transactions {
        					amount
        				}
        			}
        		}
        	}
        }
      """

      conn = post(conn, "/api", query)

      assert json_response(conn, 200) ==
               %{
                 "data" => %{
                   "expensesByCategory" => %{
                     "edges" => [
                       %{
                         "node" => %{
                           "category" => "RENT",
                           "totalSpent" => 100,
                           "transactionCount" => 1,
                           "transactions" => [%{"amount" => 100}]
                         }
                       },
                       %{
                         "node" => %{
                           "category" => "GROCERIES",
                           "totalSpent" => 400,
                           "transactionCount" => 2,
                           "transactions" => [%{"amount" => 250}, %{"amount" => 150}]
                         }
                       },
                       %{
                         "node" => %{
                           "category" => "EDUCATION",
                           "totalSpent" => 600,
                           "transactionCount" => 3,
                           "transactions" => [
                             %{"amount" => 300},
                             %{"amount" => 200},
                             %{"amount" => 100}
                           ]
                         }
                       }
                     ]
                   }
                 }
               }
    end

    test "calculates user's average monthly spending", %{user: user, conn: conn} do
      transaction_fixture(user, %{amount: 100, date: ~D[2022-01-01]})
      transaction_fixture(user, %{amount: 100, date: ~D[2022-01-02]})
      transaction_fixture(user, %{amount: 100, date: ~D[2022-01-04]})

      transaction_fixture(user, %{amount: 101, date: ~D[2023-01-01]})
      transaction_fixture(user, %{amount: 101, date: ~D[2023-01-02]})
      transaction_fixture(user, %{amount: 102, date: ~D[2023-01-04]})
      transaction_fixture(user, %{amount: 102, date: ~D[2023-01-07]})

      transaction_fixture(user, %{amount: 100, date: ~D[2023-03-01]})
      transaction_fixture(user, %{amount: 200, date: ~D[2023-03-10]})
      transaction_fixture(user, %{amount: 300, date: ~D[2023-03-21]})
      transaction_fixture(user, %{amount: 400, date: ~D[2023-03-31]})
      transaction_fixture(user, %{amount: 500, date: ~D[2023-03-31]})

      query = """
        query {
        	averageMonthlySpending(first: 3) {
        		edges {
        			node {
        				average
        				month
        			}
        		}
        	}
        }
      """

      conn = post(conn, "/api", query)

      assert json_response(conn, 200) ==
               %{
                 "data" => %{
                   "averageMonthlySpending" => %{
                     "edges" => [
                       %{"node" => %{"average" => 100.0, "month" => "2022-1"}},
                       %{"node" => %{"average" => 101.5, "month" => "2023-1"}},
                       %{"node" => %{"average" => 300.0, "month" => "2023-3"}}
                     ]
                   }
                 }
               }
    end
  end
end
