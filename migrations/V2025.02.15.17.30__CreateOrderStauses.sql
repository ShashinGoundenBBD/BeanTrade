IF OBJECT_ID('dbo.OrderStatuses','U') IS NOT NULL
    DROP TABLE dbo.OrderStatuses
GO

CREATE TABLE [OrderStatuses] (
  [StatusId] INT PRIMARY KEY IDENTITY(1, 1),
  [Status] VARCHAR(20) NOT NULL,
  [Description] VARCHAR(100)
)
GO