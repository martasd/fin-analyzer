# Fintech Transaction Analyzer API

Transaction analyzer API using Elixir and the Phoenix framework. This application will allow users to upload financial transaction data in CSV format, and it will provide insights and statistics about the transactions. The focus of this project is to assess the candidate's ability to handle data processing, implement financial calculations.

## Required Features
1. User Authentication: 
- Implement user registration, login, and logout functionality. Users should only be able to see their own uploaded data.
2. Transaction Upload:
- Users should be able to upload a CSV file containing transaction data.
- The application should parse the CSV data, validate its structure, and store it in the database.
- Each transaction entry should include fields like date, amount, description, and category.
3. Transaction Categorization:
- Implement a feature that allows users to manually categorize transactions (e.g., groceries, rent, entertainment).
4. Expense Analysis:
- Provide insights such as average monthly spending, largest expenses, and expense breakdown by category.

## Bonus
1. A basic UI for exercising the API
2. Budgeting:
- Implement a budgeting feature where users can set spending limits for different categories and receive alerts when they exceed them.
3. Currency Conversion:
- If transactions involve multiple currencies, provide an option to convert amounts to a user's preferred currency.
