IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[LockUserInventory]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[LockUserInventory]
END

-- Helper procedure to lock inventory for sell orders
CREATE PROCEDURE LockUserInventory
    @UserID INT,
    @BeanID INT,
    @QuantityToLock INT
AS
BEGIN
    UPDATE Inventory
    SET LockedQuantity = LockedQuantity + @QuantityToLock
    WHERE UserID = @UserID 
    AND BeanID = @BeanID
    AND AvailableQuantity >= @QuantityToLock
    
    IF @@ROWCOUNT = 0
        RAISERROR ('Insufficient Inventory available to lock', 16, 1)END
GO