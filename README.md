# Fintech Transaction Analyzer API

This application implements transaction analyzer GraphQL API in Elixir using the Phoenix framework. It allows users to
upload financial transaction data in CSV format and provides insights and statistics about the uploaded transactions.

## Set up

Assuming Erlang, Elixir, and Postgres are installed, clone the repo and enter its directory.

* Install and compile dependencies:

```elixir
mix deps.get
mix deps.compile
```

* Configure the database:

The default dev database options are configured in `config/dev.exs`

```elixir
config :fin_analyzer, FinAnalyzer.Repo
```

Set the username, password, or database name according to your preference.

* Create the database:

```elixir
mix ecto.create
```

* Run migrations:

```elixir
mix ecto.migrate
```

* Run the Phoenix server:

```elixir
mix phx.server
```


## Usage

The following GraphQL queries and mutations are available to interact with the API.


### Authenticate user

First, we register a new user:

```graphql
mutation {
  registerUser(email: "martin@profiq.com", password:"super-secret") {
    id
    email
  }
}
```
and log in by generating a token:

```graphql
mutation {
  logIn(email: "martin@profiq.com", password:"super-secret") {
    token
  }
}
```

Once we have a user token, we can use it to authenticate transaction queries by including it as the value of the `Authorization` header.

When we are done, we can log out which deletes the user token:

```graphql
mutation {
  logOut
}
```

### Create, show, and categorize transactions

When in possession of the auth token, execute the following mutation to upload
transactions stored in a sample CSV file `data/transaction.csv`:

```bash
curl -X POST \
-H "authorization: <auth-token>" \
-F query="mutation { uploadTransactions(transactions: \"transactions_csv\")}" \
-F transactions_csv=@data/transactions.csv \
localhost:4000/api
```

The provided sample file contains 78 transactions for testing. 

We have used Relay's connection for some fields including transactions. This is how we show all uploaded transactions for our user:

```graphql
query {
  transactions(first:78) {
    edges {
      node {
        id
        date
        amount
        category
      }
    }
  }
}
```

Each transaction already has a category assigned. This is how we can change the transaction category:

```graphql
mutation {
  categorizeTransaction(
    id: "<transaction-uuid>"
    category: SPORTS) {
    id
    category
  }
}
```


### Analyze transactions

Finally, we can gain some insights into the user's spending by analyzing them.

* We can show the largest expenses in descending order by amount:

```graphql
query {
  largestExpenses(first: 5) {
    edges {
      node {
        description
        amount
        date
      }
    }
  }
}
```

* We can display average amount spent for each month:

```graphql
query {
  averageMonthlySpending {
    month
    average
  }
}
```

* Finally, we can see some statistics for a category:

```graphql
query {
  categoryStats(category: ENTERTAINMENT) {
    category
    totalSpent
    transactionCount
  }
}
```

**NOTE:** All GraphQL queries and mutations can be imported into Insomnia client using `insomnia_export.json`
file, which is included in this repo.

## Testing

`phx.gen.auth` generated tests for the `Accounts` context. Creating `Transactions` context then generated tests for
its context. I've added HTTP tests for those queries and mutations that I implemented for transactions and analysis API:

To execute all tests:

```elixir
mix test
```

To execute only HTTP tests for GraphQL API:

```elixir
mix test test/fin_analyzer_web/schema
```

## Design Decisions

The task assignment clearly described the functionality to be implemented. The queries and mutations followed naturally
from the description. One design decision was to sort retrieved transactions by date and amount in descending order,
which makes the queries' outcomes deterministic. One useful enhancement is to use Absinthe with Relay to allow for paginating
results. This offers more flexibility to the API consumer for navigating query responses.

In the transaction import via CSV, I implemented best-effort import. Thus, rows which contain
valid data get imported while rows with invalid data are reported in errors as in the following example:

```json
{
  "data": {
    "uploadTransactions": {
      "errors": [
        {
          "row": 2,
          "validation": [
            "Date can't be blank",
            "Amount can't be blank"
          ]
        },
        {
          "row": 3,
          "validation": [
            "Category can't be blank"
          ]
        }
      ],
      "result": "sucessfully uploaded 76 transactions"
    }
  }
}
```
### Analysis: Elixir vs. SQL

Initially, I computed the average monthly spending and category breakdown
statistics with Elixir using the list of all user transactions returned from the
database. It turns out that this approach is inefficient compared to computing
these directly with SQL (or Ecto where supported) using SQL aggregate functions
COUNT, SUM, and AVG. Using these significantly improved the query response
times.

Below are the response time comparisons of the original implementation in
Elixir and the new implementation with SQL aggregate functions when querying
a database where the user has 147 965 transactions.

#### Average monthly spending

| Query                      | averageMonthly | averageMonthlySql |
| -------------------------- | -------------- | ----------------- |
|                            | 2950           | 592               |
|                            | 2790           | 105               |
|                            | 2810           | 108               |
|                            | 2880           | 102               |
|                            | 2440           | 94                |
| Average response time (ms) | 2774           | 200.2             |

For average monthly spending statistics, the SQL query is **13.8 times faster**.


#### Category breakdown

| Query                      | categoryStats | categoryStatsSql |
| -------------------------- | ------------- | ---------------- |
|                            | 1290          | 485              |
|                            | 939           | 95               |
|                            | 884           | 98               |
|                            | 728           | 81               |
|                            | 796           | 85               |
| Average response time (ms) | 927.4         | 168.8            |

For category breakdown, the SQL query is **5.5 times faster**.
