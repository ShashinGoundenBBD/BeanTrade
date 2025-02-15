IF OBJECT_ID('dbo.TransactionTypes','U') IS NOT NULL
    DROP TABLE dbo.TransactionTypes
GO

CREATE TABLE [TransactionTypes] (
  [TransactionTypeId] INT PRIMARY KEY IDENTITY(1, 1),
  [Type] VARCHAR(20) NOT NULL,
  [Description] VARCHAR(100)
)
GO