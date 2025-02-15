IF OBJECT_ID('dbo.Wallets','U') IS NOT NULL
    DROP TABLE dbo.Wallets
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