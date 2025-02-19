ALTER TABLE [dbo].[Beans] ALTER COLUMN [Description] varchar(500) NOT NULL

ALTER TABLE [dbo].[Beans] ALTER COLUMN [isActive] bit NOT NULL

ALTER TABLE [dbo].[CurrencyCodes] ALTER COLUMN [isActive] bit NOT NULL

ALTER TABLE [dbo].[Orders] ALTER COLUMN [OrderTypeId] INT NOT NULL

ALTER TABLE [dbo].[OrderStatuses] ALTER COLUMN [Description] varchar(100) NOT NULL

ALTER TABLE [dbo].[TransactionTypes] ALTER COLUMN [Description] varchar(100) NOT NULL

ALTER TABLE [dbo].[Users] ALTER COLUMN [UserGuid] varchar(256) NOT NULL

ALTER TABLE [dbo].[Users] ALTER COLUMN [isActive] bit NOT NULL

ALTER TABLE [dbo].[Wallets] ALTER COLUMN [Balance] MONEY NOT NULL

ALTER TABLE [dbo].[Wallets] ALTER COLUMN [LockedBalance] MONEY NOT NULL

ALTER TABLE [dbo].[Wallets] ALTER COLUMN [WalletGuid] VARCHAR(36) NOT NULL




