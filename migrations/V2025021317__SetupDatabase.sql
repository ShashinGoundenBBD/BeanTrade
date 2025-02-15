CREATE TABLE [Users] (
  [UserID] INT PRIMARY KEY IDENTITY(1, 1),
  [UserGuid] VARCHAR(256) DEFAULT (CONVERT(VARCHAR(36), NEWID())),
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
