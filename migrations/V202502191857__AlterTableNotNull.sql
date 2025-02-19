ALTER TABLE [dbo].[Beans] ALTER COLUMN [Description] varchar(500) NOT NULL

ALTER TABLE [dbo].[Beans] ALTER COLUMN [isActive] bit NOT NULL

ALTER TABLE [dbo].[CurrencyCodes] ALTER COLUMN [isActive] bit NOT NULL

ALTER TABLE [Orders] DROP CONSTRAINT FK__Orders__OrderTyp__6754599E
GO

DROP INDEX [IX_Orders_Matching] ON [Orders]
GO

ALTER TABLE [dbo].[Orders] ALTER COLUMN [OrderTypeId] INT NOT NULL

ALTER TABLE [dbo].[Orders] ADD CONSTRAINT fk_OrderTypeId FOREIGN KEY (OrderTypeId) REFERENCES OrderTypes(OrderTypeId);

CREATE INDEX [IX_Orders_Matching] ON [Orders] ("BeanID", "OrderTypeId", "StatusId", "PricePerBean")
GO

ALTER TABLE [dbo].[OrderStatuses] ALTER COLUMN [Description] varchar(100) NOT NULL

ALTER TABLE [dbo].[TransactionTypes] ALTER COLUMN [Description] varchar(100) NOT NULL

ALTER TABLE [dbo].[Users] ALTER COLUMN [UserGuid] varchar(256) NOT NULL

ALTER TABLE [dbo].[Users] ALTER COLUMN [isActive] bit NOT NULL

ALTER TABLE [dbo].[Wallets] DROP COLUMN [AvailableBalance] 
GO

ALTER TABLE [dbo].[Wallets] ALTER COLUMN [Balance] MONEY NOT NULL

ALTER TABLE [dbo].[Wallets] ALTER COLUMN [LockedBalance] MONEY NOT NULL

ALTER TABLE Wallets ADD AvailableBalance AS (Balance - LockedBalance)
GO

ALTER TABLE [dbo].[Wallets] ALTER COLUMN [WalletGuid] VARCHAR(36) NOT NULL




