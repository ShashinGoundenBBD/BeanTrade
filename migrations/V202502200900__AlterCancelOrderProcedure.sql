ALTER TABLE [dbo].[Orders] DROP COLUMN [ExpiryDate];
GO

ALTER TABLE [dbo].[Orders] ADD [ExpiryDate] AS DATEADD(day, 30, CAST([OrderDate] AS DATE));
GO