IF OBJECT_ID('dbo.OrderTypes','U') IS NOT NULL
    DROP TABLE dbo.OrderTypes
GO

CREATE TABLE [OrderTypes] (
  [OrderTypeId] Int PRIMARY KEY IDENTITY(1, 1),
  [OrderType] varchar(4) NOT NULL
)
GO