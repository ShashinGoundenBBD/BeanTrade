IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'TR_Users_Deactivate' AND [type] = 'TR')
BEGIN
      DROP TRIGGER [dbo].[TR_Users_Deactivate];
END;

-- Create trigger for user deactivation
CREATE OR ALTER TRIGGER TR_Users_Deactivate
ON Users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(IsActive)
    BEGIN
        UPDATE Orders
        SET StatusId = 3  -- Cancelled
        FROM Orders o
        INNER JOIN inserted i ON o.UserID = i.UserID
        WHERE i.IsActive = 0  -- User was deactivated
        AND o.StatusId = 1;   -- Order is active
    END
END;
GO