IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BeanTrade')
BEGIN
    CREATE DATABASE BeanTrade;
END
GO

USE BeanTrade;
GO

CREATE TABLE [Users] (
  [UserID] INT PRIMARY KEY IDENTITY(1, 1),
  [UserGuid] VARCHAR(256),
  [CreatedAt] DATETIME2 DEFAULT (GETUTCDATE()),
  [LastLoginAt] DATETIME2,
  [IsActive] BIT DEFAULT (1)
)
GO

CREATE TABLE [Wallets] (
  [WalletID] INT PRIMARY KEY IDENTITY(1, 1),
  [UserID] INT NOT NULL,
  [CurrencyCodeId] INT NOT NULL,
  [Balance] money DEFAULT (0),
  [LockedBalance] money DEFAULT (0),
  [LastUpdated] DATETIME2 DEFAULT (GETUTCDATE()),
  [WalletGuid] VARCHAR(36) DEFAULT (CONVERT(VARCHAR(36), NEWID()))
)
GO

CREATE TABLE [Beans] (
  [BeanID] INT PRIMARY KEY IDENTITY(1, 1),
  [Symbol] VARCHAR(10) UNIQUE NOT NULL,
  [Name] VARCHAR(100) NOT NULL,
  [Description] VARCHAR(500),
  [IsActive] BIT DEFAULT (1),
  [CreatedAt] DATETIME2 DEFAULT (GETUTCDATE())
)
GO

CREATE TABLE [Inventory] (
  [InventoryID] INT PRIMARY KEY IDENTITY(1, 1),
  [UserID] INT NOT NULL,
  [BeanID] INT NOT NULL,
  [Quantity] INT NOT NULL DEFAULT (0),
  [LockedQuantity] INT NOT NULL DEFAULT (0),
  [LastUpdated] DATETIME2 DEFAULT (GETUTCDATE())
)
GO

CREATE TABLE [OrderStatuses] (
  [StatusId] INT PRIMARY KEY IDENTITY(1, 1),
  [Status] VARCHAR(20) NOT NULL,
  [Description] VARCHAR(100)
)
GO

CREATE TABLE [OrderTypes] (
  [OrderTypeId] Int PRIMARY KEY IDENTITY(1, 1),
  [OrderType] varchar(4) NOT NULL
)
GO

CREATE TABLE [Orders] (
  [OrderID] BIGINT PRIMARY KEY IDENTITY(1, 1),
  [UserID] INT NOT NULL,
  [BeanID] INT NOT NULL,
  [CurrencyCodeId] INT NOT NULL,
  [OrderTypeId] Int,
  [StatusId] INT NOT NULL,
  [PricePerBean] Money NOT NULL,
  [Quantity] INT NOT NULL,
  [RemainingQuantity] INT NOT NULL,
  [OrderDate] DATETIME2 DEFAULT (GETUTCDATE()),
  [ExpiryDate] DATETIME2
)
GO

CREATE TABLE [Trades] (
  [TradeID] INT PRIMARY KEY IDENTITY(1, 1),
  [BuyOrderID] BIGINT NOT NULL,
  [SellOrderID] BIGINT NOT NULL,
  [Quantity] INT NOT NULL,
  [CreatedAt] DATETIME2 DEFAULT (GETUTCDATE())
)
GO

CREATE TABLE [TransactionTypes] (
  [TransactionTypeId] INT PRIMARY KEY IDENTITY(1, 1),
  [Type] VARCHAR(20) NOT NULL,
  [Description] VARCHAR(100)
)
GO

CREATE TABLE [Transactions] (
  [TransactionID] INT PRIMARY KEY IDENTITY(1, 1),
  [WalletID] INT NOT NULL,
  [TransactionTypeId] INT NOT NULL,
  [Amount] money NOT NULL,
  [Balance] money NOT NULL,
  [StatusId] INT NOT NULL,
  [CreatedAt] DATETIME2 DEFAULT (GETUTCDATE()),
  [CompletedAt] DATETIME2
)
GO

CREATE TABLE [CurrencyCodes] (
  [CurrencyCodeId] INT PRIMARY KEY IDENTITY(1, 1),
  [CurrencyCode] VARCHAR(10) UNIQUE NOT NULL,
  [Name] VARCHAR(50) NOT NULL,
  [IsActive] BIT DEFAULT (1)
)
GO


CREATE UNIQUE INDEX [UQ_Wallet_User_Currency] ON [Wallets] ("UserID", "CurrencyCodeId")
GO

CREATE UNIQUE INDEX [UQ_Inventory_User_Product] ON [Inventory] ("UserID", "BeanID")
GO

CREATE INDEX [IX_Orders_UserID_Status] ON [Orders] ("UserID", "StatusId")
GO

CREATE INDEX [IX_Orders_Matching] ON [Orders] ("BeanID", "OrderTypeId", "StatusId", "PricePerBean")
GO

CREATE INDEX [IX_Trades_BuyOrder] ON [Trades] ("BuyOrderID")
GO

CREATE INDEX [IX_Trades_SellOrder] ON [Trades] ("SellOrderID")
GO

CREATE UNIQUE INDEX [UQ_Trade_Orders] ON [Trades] ("BuyOrderID", "SellOrderID")
GO

CREATE INDEX [IX_Transactions_Wallet] ON [Transactions] ("WalletID")
GO

CREATE INDEX [IX_Transactions_WalletStatus] ON [Transactions] ("WalletID", "StatusId")
GO

ALTER TABLE [Wallets] ADD FOREIGN KEY ([UserID]) REFERENCES [Users] ([UserID])
GO

ALTER TABLE [Wallets] ADD FOREIGN KEY ([CurrencyCodeId]) REFERENCES [CurrencyCodes] ([CurrencyCodeId])
GO

ALTER TABLE [Inventory] ADD FOREIGN KEY ([UserID]) REFERENCES [Users] ([UserID])
GO

ALTER TABLE [Inventory] ADD FOREIGN KEY ([BeanID]) REFERENCES [Beans] ([BeanID])
GO

ALTER TABLE [Orders] ADD FOREIGN KEY ([UserID]) REFERENCES [Users] ([UserID])
GO

ALTER TABLE [Orders] ADD FOREIGN KEY ([BeanID]) REFERENCES [Beans] ([BeanID])
GO

ALTER TABLE [Orders] ADD FOREIGN KEY ([CurrencyCodeId]) REFERENCES [CurrencyCodes] ([CurrencyCodeId])
GO

ALTER TABLE [Orders] ADD FOREIGN KEY ([StatusId]) REFERENCES [OrderStatuses] ([StatusId])
GO

ALTER TABLE [Trades] ADD FOREIGN KEY ([BuyOrderID]) REFERENCES [Orders] ([OrderID])
GO

ALTER TABLE [Trades] ADD FOREIGN KEY ([SellOrderID]) REFERENCES [Orders] ([OrderID])
GO

ALTER TABLE [Orders] ADD FOREIGN KEY ([OrderTypeId]) REFERENCES [OrderTypes] ([OrderTypeId])
GO

ALTER TABLE [Transactions] ADD FOREIGN KEY ([WalletID]) REFERENCES [Wallets] ([WalletID])
GO

ALTER TABLE [Transactions] ADD FOREIGN KEY ([TransactionTypeId]) REFERENCES [TransactionTypes] ([TransactionTypeId])
GO


-- Add computed columns
ALTER TABLE Wallets ADD AvailableBalance AS (Balance - LockedBalance)
GO

ALTER TABLE Inventory ADD AvailableQuantity AS (Quantity - LockedQuantity)
GO

-- Add constraints
ALTER TABLE Orders ADD CONSTRAINT CHK_Orders_Quantity 
    CHECK (Quantity > 0 AND RemainingQuantity <= Quantity)
GO

ALTER TABLE Orders ADD CONSTRAINT CHK_Orders_Price
    CHECK (PricePerBean > 0)
GO

ALTER TABLE Trades ADD CONSTRAINT CHK_Trades_Quantity
    CHECK (Quantity > 0)
GO

ALTER TABLE Wallets ADD CONSTRAINT CHK_Wallets_Balances
    CHECK (Balance >= 0 AND LockedBalance >= 0)
GO

ALTER TABLE Inventory ADD CONSTRAINT CHK_Inventory_Quantities
    CHECK (Quantity >= 0 AND LockedQuantity >= 0)
GO

-- Helper procedure to lock funds for buy orders
CREATE PROCEDURE LockUserFunds
    @UserID INT,
    @CurrencyCodeId INT,
    @AmountToLock MONEY
AS
BEGIN
    UPDATE Wallets 
    SET LockedBalance = LockedBalance + @AmountToLock
    WHERE UserID = @UserID 
    AND CurrencyCodeId = @CurrencyCodeId
    AND AvailableBalance >= @AmountToLock
    
    IF @@ROWCOUNT = 0
        RAISERROR ('Insufficient funds available to lock', 16, 1)END
GO

-- Helper procedure to lock inventory for sell orders
CREATE PROCEDURE LockUserInventory
    @UserID INT,
    @BeanID INT,
    @QuantityToLock INT
AS
BEGIN
    UPDATE Inventory
    SET LockedQuantity = LockedQuantity + @QuantityToLock
    WHERE UserID = @UserID 
    AND BeanID = @BeanID
    AND AvailableQuantity >= @QuantityToLock
    
    IF @@ROWCOUNT = 0
        RAISERROR ('Insufficient Inventory available to lock', 16, 1)END
GO



-- Helper function to get order details
CREATE OR ALTER FUNCTION GetOrderDetails(
    @OrderID BIGINT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        OrderID,
        UserID,
        BeanID,
        OrderTypeId,
        CurrencyCodeId,
        PricePerBean,
        RemainingQuantity,
        StatusId
    FROM Orders
    WHERE OrderID = @OrderID
)
GO

CREATE OR ALTER PROCEDURE ProcessTrade
    @BuyOrderID BIGINT,
    @SellOrderID BIGINT,
    @MatchedQuantity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @BuyerID INT, @SellerID INT, @BeanID INT, 
                @BuyerCurrencyId INT, @SellerCurrencyId INT,
                @BuyerPrice MONEY, @SellerPrice MONEY

        -- Get order details using the new function
        SELECT @BuyerID = UserID, @BeanID = BeanID, 
               @BuyerPrice = PricePerBean, @BuyerCurrencyId = CurrencyCodeId
        FROM GetOrderDetails(@BuyOrderID)

        SELECT @SellerID = UserID, @SellerPrice = PricePerBean, 
               @SellerCurrencyId = CurrencyCodeId
        FROM GetOrderDetails(@SellOrderID)

        -- Verify same currency
        IF @BuyerCurrencyId != @SellerCurrencyId
        BEGIN
            RAISERROR ('Currency mismatch between orders', 16, 1)
            RETURN
        END

        BEGIN TRANSACTION

        -- Create trade record
        INSERT INTO Trades (BuyOrderID, SellOrderID, Quantity)
        VALUES (@BuyOrderID, @SellOrderID, @MatchedQuantity)

        -- Update order quantities
        UPDATE Orders 
        SET RemainingQuantity = RemainingQuantity - @MatchedQuantity
        WHERE OrderID IN (@BuyOrderID, @SellOrderID)

        -- Calculate amounts
        DECLARE @BuyerAmount MONEY = @MatchedQuantity * @BuyerPrice
        DECLARE @SellerAmount MONEY = @MatchedQuantity * @SellerPrice

        -- Update buyer's wallet and inventory
        UPDATE Wallets
        SET Balance = Balance - @BuyerAmount,
            LockedBalance = LockedBalance - @BuyerAmount
        WHERE UserID = @BuyerID AND CurrencyCodeId = @BuyerCurrencyId

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK
            RAISERROR ('Failed to update buyer wallet', 16, 1)
            RETURN
        END

        UPDATE Inventory
        SET Quantity = Quantity + @MatchedQuantity
        WHERE UserID = @BuyerID AND BeanID = @BeanID

        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO Inventory (UserID, BeanID, Quantity)
            VALUES (@BuyerID, @BeanID, @MatchedQuantity)
        END

        -- Update seller's wallet and inventory
        UPDATE Wallets
        SET Balance = Balance + @SellerAmount
        WHERE UserID = @SellerID AND CurrencyCodeId = @SellerCurrencyId

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK
            RAISERROR ('Failed to update seller wallet', 16, 1)
            RETURN
        END

        UPDATE Inventory
        SET Quantity = Quantity - @MatchedQuantity,
            LockedQuantity = LockedQuantity - @MatchedQuantity
        WHERE UserID = @SellerID AND BeanID = @BeanID

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK
            RAISERROR ('Failed to update seller inventory', 16, 1)
            RETURN
        END

        -- Create transaction records
        INSERT INTO Transactions (WalletID, TransactionTypeId, Amount, Balance, StatusId)
        SELECT 
            w.WalletID, 
            1, -- Trade transaction type
            CASE WHEN w.UserID = @BuyerID THEN -@BuyerAmount ELSE @SellerAmount END,
            w.Balance,
            1  -- Completed status
        FROM Wallets w
        WHERE w.UserID IN (@BuyerID, @SellerID)
        AND w.CurrencyCodeId IN (@BuyerCurrencyId, @SellerCurrencyId)

        COMMIT
        PRINT 'Trade processed successfully'
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK
        PRINT ERROR_MESSAGE()
    END CATCH
END
GO


-- MatchOrders procedure
CREATE OR ALTER PROCEDURE MatchOrders
    @OrderID BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BeanID INT, @OrderTypeId INT, @PricePerBean MONEY, @RemainingQuantity INT,
            @UserID INT, @CurrencyCodeId INT

    -- Get order details using function made
    SELECT 
        @BeanID = BeanID,
        @OrderTypeId = OrderTypeId,
        @PricePerBean = PricePerBean,
        @RemainingQuantity = RemainingQuantity,
        @UserID = UserID,
        @CurrencyCodeId = CurrencyCodeId
    FROM GetOrderDetails(@OrderID)

    -- If order is already complete
    IF @RemainingQuantity = 0
        RETURN

    -- Find matching orders
    DECLARE @MatchedOrders TABLE (
        OrderID BIGINT,
        MatchQuantity INT,
        PricePerBean MONEY,
        RowNum INT
    )

    IF @OrderTypeId = 1 -- Buy Order, conditions <= 
    BEGIN
        INSERT INTO @MatchedOrders
        SELECT 
            o.OrderID,
            CASE --- Logic for checking what the quanity matched would be 
                WHEN o.RemainingQuantity <= @RemainingQuantity 
                THEN o.RemainingQuantity 
                ELSE @RemainingQuantity 
            END as MatchQuantity,
            o.PricePerBean,
            ROW_NUMBER() OVER (ORDER BY o.PricePerBean ASC, o.OrderDate ASC) as RowNum
        FROM Orders o
        WHERE o.BeanID = @BeanID
            AND o.OrderTypeId = 2 -- Sell orders
            AND o.StatusId = 1 -- Active
            AND o.CurrencyCodeId = @CurrencyCodeId -- Match same currency only
            AND o.PricePerBean <= @PricePerBean -- less than or equal to our buy price
            AND o.OrderID != @OrderID
            AND o.UserID != @UserID
    END
    ELSE -- Sell Order
    BEGIN
        INSERT INTO @MatchedOrders
        SELECT 
            o.OrderID,
            CASE --- same logic as above for quantity matching
                WHEN o.RemainingQuantity <= @RemainingQuantity 
                THEN o.RemainingQuantity 
                ELSE @RemainingQuantity 
            END as MatchQuantity,
            o.PricePerBean,
            ROW_NUMBER() OVER (ORDER BY o.PricePerBean DESC, o.OrderDate ASC) as RowNum
        FROM Orders o
        WHERE o.BeanID = @BeanID
            AND o.OrderTypeId = 1 -- Buy orders
            AND o.StatusId = 1 -- Active
            AND o.CurrencyCodeId = @CurrencyCodeId -- Match same currency only
            AND o.PricePerBean >= @PricePerBean -- need buys >= to our sell
            AND o.OrderID != @OrderID
            AND o.UserID != @UserID
    END

    -- Process each match
    DECLARE @CurrentMatch BIGINT, @MatchQuantity INT, @MatchPrice MONEY
    DECLARE @LocalBuyOrderID BIGINT, @LocalSellOrderID BIGINT

    --- Make use of cursor so you can go through multiple matches "e.g think of 3 partial can do it all once"
    DECLARE @MatchCursor CURSOR

    SET @MatchCursor = CURSOR FOR
    SELECT OrderID, MatchQuantity, PricePerBean
    FROM @MatchedOrders
    ORDER BY RowNum

    OPEN @MatchCursor
    FETCH NEXT FROM @MatchCursor INTO @CurrentMatch, @MatchQuantity, @MatchPrice

    WHILE @@FETCH_STATUS = 0 AND @RemainingQuantity > 0 --- We go through matches until fufilled
    BEGIN
        BEGIN TRY
            IF @OrderTypeId = 1
            BEGIN
                SET @LocalBuyOrderID = @OrderID --- need to get this information for our processtrade call
                SET @LocalSellOrderID = @CurrentMatch
            END
            ELSE
            BEGIN
                SET @LocalBuyOrderID = @CurrentMatch
                SET @LocalSellOrderID = @OrderID
            END

            -- Process the trade
            EXEC ProcessTrade @LocalBuyOrderID, @LocalSellOrderID, @MatchQuantity
            SET @RemainingQuantity = @RemainingQuantity - @MatchQuantity
            PRINT 'Successfully processed trade for OrderID: ' + CAST(@CurrentMatch AS VARCHAR(20))

        END TRY
        BEGIN CATCH
            PRINT 'Error processing trade for OrderID: ' + CAST(@CurrentMatch AS VARCHAR(20))
            PRINT ERROR_MESSAGE()
        END CATCH

        FETCH NEXT FROM @MatchCursor INTO @CurrentMatch, @MatchQuantity, @MatchPrice
    END

    CLOSE @MatchCursor
    DEALLOCATE @MatchCursor
END
GO

-- BeforeInsert of order trigger, checks balances + inventories and isActive for currency + beans
CREATE OR ALTER TRIGGER TR_Orders_BeforeInsert
ON Orders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserID INT, @OrderTypeId INT, @Quantity INT, @PricePerBean MONEY,
            @BeanID INT, @CurrencyCodeId INT

    SELECT @UserID = UserID,
           @OrderTypeId = OrderTypeId,
           @Quantity = Quantity,
           @PricePerBean = PricePerBean,
           @BeanID = BeanID,
           @CurrencyCodeId = CurrencyCodeId
    FROM inserted

    -- Check if currency is active
    IF NOT EXISTS (
        SELECT 1 FROM CurrencyCodes 
        WHERE CurrencyCodeId = @CurrencyCodeId 
        AND IsActive = 1
    )
    BEGIN
        RAISERROR ('Selected currency is not active', 16, 1)
        RETURN
    END

    -- Check if bean is active
    IF NOT EXISTS (
        SELECT 1 FROM Beans
        WHERE BeanID = @BeanID
        AND IsActive = 1
    )
    BEGIN
        RAISERROR ('Selected bean is not active', 16, 1)
        RETURN
    END

    BEGIN TRY
        BEGIN TRANSACTION
        -- For buy orders, lock funds
        IF @OrderTypeId = 1
        BEGIN
            DECLARE @Total MONEY
            SET @Total = CAST(@Quantity AS MONEY) * @PricePerBean
            EXEC LockUserFunds @UserID, @CurrencyCodeId, @Total
        END
        -- For sell orders, lock inventory
        ELSE
        BEGIN
            EXEC LockUserInventory @UserID, @BeanID, @Quantity
        END

        -- Insert the order
        INSERT INTO Orders (
            UserID, BeanID, CurrencyCodeId, OrderTypeId, StatusId,
            PricePerBean, Quantity, RemainingQuantity, OrderDate
        )
        SELECT 
            UserID, BeanID, CurrencyCodeId, OrderTypeId, 1,
            PricePerBean, Quantity, Quantity, GETUTCDATE()
        FROM inserted

        COMMIT
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR (@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- Create AfterInsert trigger - This calls our match procedure.
CREATE OR ALTER TRIGGER TR_Orders_AfterInsert
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrderID BIGINT
    SELECT @OrderID = OrderID FROM inserted
    
    EXEC MatchOrders @OrderID
END
GO

-- UpdateStatus trigger to make life easier
CREATE OR ALTER TRIGGER TR_Orders_UpdateStatus
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Orders
    SET StatusId = 2 -- Closed
    WHERE OrderID IN (
        SELECT OrderID 
        FROM inserted 
        WHERE RemainingQuantity = 0 
        AND StatusId = 1 -- Only update if currently Active
    )
END
GO