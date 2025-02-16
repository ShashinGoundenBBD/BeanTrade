-- Insert currencies
INSERT INTO CurrencyCodes (CurrencyCode, Name)
VALUES 
    ('ZAR', 'SA Rand'),
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

