-- Clear existing data
DELETE FROM Transactions;
DELETE FROM Trades;
DELETE FROM Orders;
DELETE FROM Inventory;
DELETE FROM Wallets;
DELETE FROM Users;
DELETE FROM Beans;
DELETE FROM CurrencyCodes;
GO

-- Insert test users (100 users)
INSERT INTO Users (IsActive)
SELECT 1
FROM GENERATE_SERIES(1, 100);
GO

-- Insert currencies
INSERT INTO CurrencyCodes (CurrencyCode, Name)
VALUES 
    ('ZAR', 'SA Rand')
    ('USD', 'US Dollar'),
    ('EUR', 'Euro');
GO

-- Insert beans
INSERT INTO Beans (Symbol, Name, Description)
VALUES 
    ('ARBCA', 'Arabica', 'Premium Arabica Coffee Beans'),
    ('RBSTA', 'Robusta', 'Strong Robusta Coffee Beans'),
    ('KONA', 'Kona', 'Hawaiian Kona Coffee Beans');
GO

-- Insert order types
INSERT INTO OrderTypes (OrderType)
VALUES 
    ('BUY'),     -- OrderTypeId 1
    ('SELL');    -- OrderTypeId 2
GO

-- Insert order statuses
INSERT INTO OrderStatuses (Status, Description)
VALUES 
    ('Active', 'Order is active and can be matched'),          -- StatusId 1
    ('Closed', 'Order has been fully filled'),                 -- StatusId 2
    ('Cancelled', 'Order was cancelled by user'),              -- StatusId 3
    ('Expired', 'Order reached its expiry date');             -- StatusId 4
GO

-- Insert transaction types
INSERT INTO TransactionTypes (Type, Description)
VALUES 
    ('Trade', 'Bean trade transaction'),            -- TransactionTypeId 1
    ('Deposit', 'Money deposited into wallet'),     -- TransactionTypeId 2
    ('Withdraw', 'Money withdrawn from wallet'),    -- TransactionTypeId 3
	('Cancelled/Expired', 'Trade was cancelled/expired, money returned');    -- TransactionTypeId 4
GO

-- Give some users ZAR balances (Users 1-20)
INSERT INTO Wallets (UserID, CurrencyCodeId, Balance)
SELECT 
    UserID,
    1, -- ZAR
    50000.00
FROM Users
WHERE UserID <= 20;
GO

-- Give some users USD balances (Users 21-40)
INSERT INTO Wallets (UserID, CurrencyCodeId, Balance)
SELECT 
    UserID,
    2, -- USD
    45000.00
FROM Users
WHERE UserID BETWEEN 21 AND 40;
GO

-- Give some users EUR balances (Users 41-60)
INSERT INTO Wallets (UserID, CurrencyCodeId, Balance)
SELECT 
    UserID,
    3, -- EUR
    40000.00
FROM Users
WHERE UserID BETWEEN 41 AND 60;
GO

-- Give some users Arabica inventory (Users 61-70)
INSERT INTO Inventory (UserID, BeanID, Quantity)
SELECT 
    UserID,
    1, -- Arabica
    5000
FROM Users
WHERE UserID BETWEEN 61 AND 70;
GO

-- Give some users Robusta inventory (Users 71-80)
INSERT INTO Inventory (UserID, BeanID, Quantity)
SELECT 
    UserID,
    2, -- Robusta
    4000
FROM Users
WHERE UserID BETWEEN 71 AND 80;
GO

-- Give some users Kona inventory (Users 81-90)
INSERT INTO Inventory (UserID, BeanID, Quantity)
SELECT 
    UserID,
    3, -- Kona
    3000
FROM Users
WHERE UserID BETWEEN 81 AND 90;
GO