IF OBJECT_ID('dbo.Transactions','U') IS NOT NULL
    DROP TABLE dbo.Transactions
GO

CREATE TABLE [Transactions] (
  [TransactionID] INT PRIMARY KEY IDENTITY(1, 1),
  [WalletID] INT NOT NULL,
  [TransactionTypeId] INT NOT NULL,
  [Amount] money NOT NULL,
  [Balance] money NOT NULL,
  --[StatusId] INT NOT NULL,
  [CreatedAt] DATETIME2 DEFAULT (GETUTCDATE()),
  [CompletedAt] DATETIME2
)
GO