CREATE PROCEDURE UnlockUserInventory
    @UserID INT,
    @BeanID INT,
    @QuantityToUnlock INT
AS
BEGIN
    UPDATE Inventory
    SET LockedQuantity = LockedQuantity - @QuantityToUnlock, Quantity = Quantity + @QuantityToUnlock
    WHERE UserID = @UserID 
    AND BeanID = @BeanID
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR ('Insufficient Inventory available to unlock', 16, 1);
    END
END
GO