IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'TR_Orders_AfterInsert' AND [type] = 'TR')
BEGIN
      DROP TRIGGER [dbo].[TR_Orders_AfterInsert];
END;
GO

-- Create AfterInsert trigger - This calls our match procedure.
CREATE OR ALTER TRIGGER TR_Orders_AfterInsert
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrderID BIGINT
    SELECT @OrderID = OrderID FROM inserted
    
    EXEC MatchOrders @OrderID
END
GO