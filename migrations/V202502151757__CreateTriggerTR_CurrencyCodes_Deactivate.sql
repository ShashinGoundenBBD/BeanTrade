IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'TR_CurrencyCodes_Deactivate' AND [type] = 'TR')
BEGIN
      DROP TRIGGER [dbo].[TR_CurrencyCodes_Deactivate];
END;
GO

-- Create trigger for currency deactivation
CREATE OR ALTER TRIGGER TR_CurrencyCodes_Deactivate
ON CurrencyCodes
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(IsActive)
    BEGIN
        UPDATE Orders
        SET StatusId = 3  -- Cancelled
        FROM Orders o
        INNER JOIN inserted i ON o.CurrencyCodeId = i.CurrencyCodeId
        WHERE i.IsActive = 0  -- Currency was deactivated
        AND o.StatusId = 1;   -- Order is active
    END
END;
GO