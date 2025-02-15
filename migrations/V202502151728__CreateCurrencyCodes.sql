IF OBJECT_ID('dbo.CurrencyCodes','U') IS NOT NULL
    DROP TABLE dbo.CurrencyCodes
GO

CREATE TABLE [CurrencyCodes] (
  [CurrencyCodeId] INT PRIMARY KEY IDENTITY(1, 1),
  [CurrencyCode] VARCHAR(10) UNIQUE NOT NULL,
  [Name] VARCHAR(50) NOT NULL,
  [IsActive] BIT DEFAULT (1)
)
GO