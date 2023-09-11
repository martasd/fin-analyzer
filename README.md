# Fintech Transaction Analyzer API

This application implements transaction analyzer GraphQL API in Elixir using the Phoenix framework. It allows users to
upload financial transaction data in CSV format and provides insights and statistics about the uploaded transactions.

## Set up

Assuming Erlang, Elixir, and Postgres are installed, clone the repo and enter its directory.

* Install and compile dependencies

```elixir
mix deps.get
mix deps.compile
```

* Create the database

```elixir
mix ecto.create
```

* Run migrations

```elixir
mix ecto.migrate
```

* Run the Phoenix server

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
and login by generating a token:

```graphql
query {
  getUserToken(email: "martin@profiq.com")
}
```

Once we have a user token, we can use it to authenticate transaction queries by including it as the value of the `Authorization` header.


### Create, show, and categorize transactions

To upload transactions stored in a sample CSV file, execute the following mutation:

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
  averageMonthlySpending(first: 3) {
    edges {
      node {
        average
        month
      }
    }
  }
}
```

* Finally, we can see some statistics for each category:

```graphql
query {
  expensesByCategory(first: 10) {
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
```

If we are interested only in a specific category, we can use a filter like this:

```graphql
expensesByCategory(first: 3, category: GROCERIES)
```

*NOTE:* All GraphQL queries and mutations can be imported into Insomnia client using `insomnia_graphql_collection.json`
export file, which is included in this repo.

## Design

The task assignment clearly described the functionality to be implemented. The queries and mutations followed naturally
from the description. One design decision was to sort retrieved transactions by date and amount in descending order,
which makes the queries' outcomes deterministic. One useful enhancement is to use Absinthe with Relay to allow for paginating
results. This offers more flexibility to the API consumer for navigating query responses.


## Challenges

I found that the biggest challenge was to figure out the user authentication for the GraphQL API. Authentication does
come out of the box with Phoenix with `mix phx.gen.auth`. It took some time to figure out how to properly hook into it
to fetch the current user for Abisnthe API calls.
