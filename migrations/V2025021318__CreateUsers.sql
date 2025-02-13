CREATE TABLE [Users] (
  [UserID] INT PRIMARY KEY IDENTITY(1, 1),
  [UserGuid] VARCHAR(256),
  [IsActive] BIT DEFAULT (1)
)
GO