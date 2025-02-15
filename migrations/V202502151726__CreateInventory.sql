IF OBJECT_ID('dbo.Inventory','U') IS NOT NULL
    DROP TABLE dbo.Inventory
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