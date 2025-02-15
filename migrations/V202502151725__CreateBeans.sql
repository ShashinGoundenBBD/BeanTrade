IF OBJECT_ID('dbo.Beans','U') IS NOT NULL
    DROP TABLE dbo.Beans
GO

CREATE TABLE [Beans] (
  [BeanID] INT PRIMARY KEY IDENTITY(1, 1),
  [Symbol] VARCHAR(10) UNIQUE NOT NULL,
  [Name] VARCHAR(100) NOT NULL,
  [Description] VARCHAR(500),
  [IsActive] BIT DEFAULT (1),
  [CreatedAt] DATETIME2 DEFAULT (GETUTCDATE())
)
GO