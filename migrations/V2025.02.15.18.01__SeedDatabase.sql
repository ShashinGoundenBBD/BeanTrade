-- Insert test users
INSERT INTO Users (UserGuid)
VALUES 
    ('user-guid-1'),  -- UserID 1
    ('user-guid-2'),  -- UserID 2
    ('user-guid-3'),  -- UserID 3
    ('user-guid-4');  -- UserID 4
GO

-- Insert currency codes
INSERT INTO CurrencyCodes (CurrencyCode, Name)
VALUES 
    ('USD', 'US Dollar'),    -- CurrencyCodeId 1
    ('EUR', 'Euro'),         -- CurrencyCodeId 2
    ('GBP', 'British Pound'); -- CurrencyCodeId 3
GO

-- Insert beans
INSERT INTO Beans (Symbol, Name, Description)
VALUES 
    ('ARBCA', 'Arabica', 'Premium Arabica Coffee Beans'),      -- BeanID 1
    ('RBSTA', 'Robusta', 'Strong Robusta Coffee Beans'),       -- BeanID 2
    ('EXPSO', 'Espresso', 'Special Espresso Blend Beans'),     -- BeanID 3
    ('DECAF', 'Decaf', 'Colombian Decaf Coffee Beans');        -- BeanID 4
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
    ('Withdraw', 'Money withdrawn from wallet');    -- TransactionTypeId 3
GO

-- Setup initial wallets with some balance
INSERT INTO Wallets (UserID, CurrencyCodeId, Balance)
VALUES 
    (1, 1, 10000.00),  -- User 1 has $10,000 USD
    (2, 1, 15000.00),  -- User 2 has $15,000 USD
    (3, 1, 20000.00),  -- User 3 has $20,000 USD
    (4, 1, 25000.00),  -- User 4 has $25,000 USD
	(1, 2, 10000.00),  -- User 1 has E10,000 USD
    (2, 2, 15000.00),  -- User 2 has E15,000 USD
    (3, 2, 20000.00),  -- User 3 has E20,000 USD
    (4, 2, 25000.00);  -- User 4 has E25,000 USD
GO

-- Setup initial inventory
INSERT INTO Inventory (UserID, BeanID, Quantity)
VALUES 
    (1, 1, 1000),  -- User 1 has 1000 Arabica
    (1, 2, 500),   -- User 1 has 500 Robusta
    (2, 1, 800),   -- User 2 has 800 Arabica
    (3, 2, 1200),  -- User 3 has 1200 Robusta
    (4, 3, 1500);  -- User 4 has 1500 Espresso
GO
