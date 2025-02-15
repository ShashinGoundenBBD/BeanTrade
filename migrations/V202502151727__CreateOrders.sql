IF OBJECT_ID('dbo.Orders','U') IS NOT NULL
    DROP TABLE dbo.Orders
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