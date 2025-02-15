IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'TR_Beans_Deactivate' AND [type] = 'TR')
BEGIN
      DROP TRIGGER [dbo].[TR_Beans_Deactivate];
END;
GO

-- Create trigger for bean deactivation
CREATE OR ALTER TRIGGER TR_Beans_Deactivate
ON Beans
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(IsActive)
    BEGIN
        UPDATE Orders
        SET StatusId = 3  -- Cancelled
        FROM Orders o
        INNER JOIN inserted i ON o.BeanID = i.BeanID
        WHERE i.IsActive = 0  -- Bean was deactivated
        AND o.StatusId = 1;   -- Order is active
    END
END;
GO