-- Insert test users (100 users)
INSERT INTO Users (IsActive)
SELECT 1
FROM (
    SELECT TOP 100 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number
    FROM master.dbo.spt_values t1
) t;
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