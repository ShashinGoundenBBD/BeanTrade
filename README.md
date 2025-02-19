# BeanTrade - Coffee Bean Trading Platform

BeanTrade is a database-driven trading platform for coffee beans, allowing users to buy and sell different types of coffee beans using various currencies.

## 🌱 Project Overview

BeanTrade enables users to:
- Trade different types of coffee beans (Arabica, Robusta, Kona)
- Manage wallets in multiple currencies (ZAR, USD, EUR)
- Place buy and sell orders
- Automatically match orders based on price and availability
- Track inventory and transaction history

## 🛠️ Technical Architecture

### Database Schema

The platform uses SQL Server with the following key tables:
- **Users**: Manages user accounts
- **Wallets**: Tracks user currency balances
- **Beans**: Available coffee bean types for trading
- **Inventory**: User bean holdings
- **Orders**: Buy and sell orders
- **Trades**: Completed transactions between users
- **Transactions**: Financial transaction history

### Key Features

- **Order Matching Engine**: Automatically matches buy and sell orders
- **Fund Locking**: Ensures users have sufficient funds/inventory before order placement
- **Transaction Processing**: Handles the movement of beans and currencies between users
- **Status Management**: Tracks orders through their lifecycle (Active, Closed, Cancelled, Expired)

## 🚀 Deployment

The project uses GitHub Actions for CI/CD with Terraform for infrastructure management:

1. **Terraform** creates and manages AWS resources
2. **Flyway** handles database migrations
3. **GitHub Actions** orchestrates the deployment workflow

## 🔧 Setup Instructions

### Deployment Process

The deployment follows this flow:
1. **Infrastructure Setup**: Terraform creates necessary AWS resources including the SQL Server database
2. **Database Migrations**: Flyway runs all SQL migrations in sequence (contained in the migrations directory)
3. **Static Data Seeding**: V202502161118__SeedDatabase.sql runs as part of the migrations to populate reference data

### Local Development Setup

For local testing after deployment:
1. Connect to the deployed database
2. Run the test data scripts:
   ```sql
   -- 1. Create test users with wallets and inventory
   seedDB.sql
   
   -- 2. Create sample orders for testing
   seedOrders.sql
   ```

### Migration Pattern

The database is built using incremental migrations:
- Each schema change is a separate migration file
- Flyway executes these in order based on version numbers
- All migrations are tracked in Flyway's schema history table

## 📊 Database Schema Details

### Core Entities

- **Users**: Core user accounts
- **Wallets**: Currency balances for users (ZAR, USD, EUR)
- **Beans**: Coffee bean types available for trading
- **Inventory**: User bean holdings

### Trading Entities

- **Orders**: Buy/sell orders with price, quantity, and status
- **Trades**: Matched orders forming completed trades
- **Transactions**: Financial record of all currency movements

### Auxiliary Tables

- **OrderStatuses**: Possible order states (Active, Closed, Cancelled, Expired)
- **OrderTypes**: Types of orders (Buy, Sell)
- **TransactionTypes**: Types of transactions (Trade, Deposit, Withdraw, Cancelled/Expired)
- **CurrencyCodes**: Supported currencies

## 🔄 Trading Mechanism

1. User places an order (buy or sell)
2. System validates and locks appropriate funds/inventory
3. Matching engine looks for compatible orders
4. When a match is found, a trade is created
5. Funds and inventory are transferred between users
6. Transaction records are created
7. Order statuses are updated

## 🔐 Security Features

- Fund locking prevents double-spending
- Inventory locking prevents selling the same beans twice
- Transaction history provides audit trail
- User activity status controls trading permissions

## 📋 Test Data

After running the migrations in production, you can load test data:
- **seedDB.sql**: Creates 100 test users with different currency balances and inventory distributions
- **seedOrders.sql**: Creates sample buy and sell orders that demonstrate the matching system

The test data includes:
- Users 1-20: Have ZAR balances
- Users 21-40: Have USD balances
- Users 41-60: Have EUR balances
- Users 61-70: Have Arabica inventory
- Users 71-80: Have Robusta inventory
- Users 81-90: Have Kona inventory

## 🧪 Testing the System

After deploying and seeding test data, you can test the trading system by executing:

```sql
-- Example: Creating a buy order
EXEC dbo.CreateBuyOrder 
    @UserId = 1,               -- User ID
    @PricePerBean = 25,        -- Price per bean
    @BeanID = 1,               -- Bean type (1=Arabica)
    @CurrencyCodeID = 1,       -- Currency (1=ZAR)
    @quantity = 100;           -- Number of beans
```

## 📚 Key Procedures

- **LockUserFunds**: Reserves currency for buy orders
- **LockUserInventory**: Reserves inventory for sell orders
- **ProcessTrade**: Handles the exchange of beans and currency
- **MatchOrders**: Finds and processes matching orders
- **ExpireOrders**: Handles expiration of old orders

## 🔄 Workflow Triggers

- **TR_Orders_BeforeInsert**: Validates order creation requirements
- **TR_Orders_AfterInsert**: Initiates order matching after creation
- **TR_Orders_UpdateStatus**: Handles order status changes
- **TR_Users_Deactivate**: Cancels orders when users are deactivated
- **TR_Beans_Deactivate**: Cancels orders when beans are deactivated
- **TR_CurrencyCodes_Deactivate**: Cancels orders when currencies are deactivated

## 👨‍💻 CI/CD Pipeline

The GitHub Actions workflow (`terraform.yaml`) handles continuous deployment:

1. **Terraform Job**:
   - Authenticates with AWS using secrets
   - Initializes Terraform with the remote state bucket
   - Plans and applies infrastructure changes
   - Outputs the database host address

2. **Flyway Job**:
   - Uses the database host from Terraform
   - Connects to the database with credentials from secrets
   - Runs all migrations in the `/migrations` directory
   - Includes the static data seeding (V202502161118__SeedDatabase.sql)

After the pipeline completes, the database is ready for testing with the seed scripts.

## 📈 Future Enhancements

Potential improvements include:
- Price history tracking and charts
- User API for programmatic trading
- Fee structure for platform sustainability
- Additional bean types and currencies
- Market analysis tools