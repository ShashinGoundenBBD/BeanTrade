IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'TR_Orders_UpdateStatus' AND [type] = 'TR')
BEGIN
      DROP TRIGGER [dbo].[TR_Orders_UpdateStatus];
END;
GO

-- Enhance the UpdateStatus trigger to handle all status changes
CREATE OR ALTER TRIGGER TR_Orders_UpdateStatus
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
	-- Auto-close fully filled orders
            UPDATE Orders
            SET StatusId = 2  -- Closed
            WHERE OrderID IN (
                SELECT OrderID 
                FROM inserted 
                WHERE RemainingQuantity = 0 
                AND StatusId = 1  -- Only update if currently Active
            );

    -- Create table to track orders needing locked resource release
    DECLARE @OrdersToRelease TABLE (
        OrderID BIGINT,
        UserID INT,
        OrderTypeId INT,
        BeanID INT,
        CurrencyCodeId INT,
        RemainingQuantity INT,
        PricePerBean MONEY
    );

    -- Capture orders that need processing (status changed from active)
    INSERT INTO @OrdersToRelease
    SELECT 
        i.OrderID,
        i.UserID,
        i.OrderTypeId,
        i.BeanID,
        i.CurrencyCodeId,
        i.RemainingQuantity,
        i.PricePerBean
    FROM inserted i
    INNER JOIN deleted d ON i.OrderID = d.OrderID
    WHERE d.StatusId = 1  -- Was active
        AND i.StatusId IN (3, 4)  --  cancelled, or expired
        AND i.RemainingQuantity > 0;  -- Still had remaining quantity

    -- If we have orders to process
    IF EXISTS (SELECT 1 FROM @OrdersToRelease)
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            -- Release locked funds for buy orders
            UPDATE w
            SET LockedBalance = w.LockedBalance - (o.RemainingQuantity * o.PricePerBean)
            FROM Wallets w
            INNER JOIN @OrdersToRelease o ON w.UserID = o.UserID 
                AND w.CurrencyCodeId = o.CurrencyCodeId
            WHERE o.OrderTypeId = 1;  -- Buy orders

            -- Release locked inventory for sell orders
            UPDATE i
            SET LockedQuantity = i.LockedQuantity - o.RemainingQuantity
            FROM Inventory i
            INNER JOIN @OrdersToRelease o ON i.UserID = o.UserID 
                AND i.BeanID = o.BeanID
            WHERE o.OrderTypeId = 2;  -- Sell orders


            -- Create transaction records for cancelled/expired orders
            INSERT INTO Transactions (
                WalletID,
                TransactionTypeId,
                Amount,
                Balance
            )
            SELECT 
                w.WalletID,
                4,  -- Expired/Cancelled transaction type
                o.RemainingQuantity * o.PricePerBean,
                w.Balance
            FROM @OrdersToRelease o
            INNER JOIN inserted i ON o.OrderID = i.OrderID
            INNER JOIN Wallets w ON o.UserID = w.UserID 
                AND o.CurrencyCodeId = w.CurrencyCodeId
            WHERE i.StatusId IN (3, 4)  -- Only for cancelled or expired orders
                AND o.OrderTypeId = 1;   -- Only for buy orders

            COMMIT;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK;
            
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR ('Error processing status change: %s', 16, 1, @ErrorMessage);
        END CATCH
    END
END;
GO