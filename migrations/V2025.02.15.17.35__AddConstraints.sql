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