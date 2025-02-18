CREATE PROCEDURE CancelOrder
    @OrderID BIGINT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @UserID INT, @CurrencyCodeId INT, @AmountToUnlock MONEY, @BeanID INT, @QuantityToUnlock INT;
		DECLARE @CancelledStatusId INT = (SELECT StatusId FROM OrderStatuses WHERE [Status] = 'Cancelled')

        SELECT 
            @UserID = UserID, 
            @CurrencyCodeId = CurrencyCodeId, 
            @AmountToUnlock = PricePerBean * Quantity,
            @BeanID = BeanID,
            @QuantityToUnlock = Quantity
        FROM Orders
        WHERE OrderID = @OrderID AND StatusId != @CancelledStatusId;

        IF @UserID IS NULL
        BEGIN
            RAISERROR('Order does not exist or is already cancelled', 16, 1);
            RETURN;
        END

        UPDATE Orders
        SET StatusId = @CancelledStatusId  
        WHERE OrderID = @OrderID;

        EXEC UnlockUserFunds @UserID, @CurrencyCodeId, @AmountToUnlock;

        EXEC UnlockUserInventory @UserID, @BeanID, @QuantityToUnlock;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        RAISERROR('An error occurred while cancelling the order: %s', 16, 1);
    END CATCH
END
GO
