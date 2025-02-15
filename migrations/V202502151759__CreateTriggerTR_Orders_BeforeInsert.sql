IF EXISTS (SELECT * FROM sys.objects WHERE [name] = N'TR_Orders_BeforeInsert' AND [type] = 'TR')
BEGIN
      DROP TRIGGER [dbo].[TR_Orders_BeforeInsert];
END;
GO

-- BeforeInsert of order trigger, checks balances + inventories and isActive for currency + beans
CREATE OR ALTER TRIGGER TR_Orders_BeforeInsert
ON Orders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserID INT, @OrderTypeId INT, @Quantity INT, @PricePerBean MONEY,
            @BeanID INT, @CurrencyCodeId INT

    SELECT @UserID = UserID,
           @OrderTypeId = OrderTypeId,
           @Quantity = Quantity,
           @PricePerBean = PricePerBean,
           @BeanID = BeanID,
           @CurrencyCodeId = CurrencyCodeId
    FROM inserted

	-- Check if user is active
    IF NOT EXISTS (
        SELECT 1 FROM Users 
        WHERE UserID = @UserID 
        AND IsActive = 1
    )
    BEGIN
        RAISERROR ('User account is not active', 16, 1)
        RETURN
    END

    -- Check if currency is active
    IF NOT EXISTS (
        SELECT 1 FROM CurrencyCodes 
        WHERE CurrencyCodeId = @CurrencyCodeId 
        AND IsActive = 1
    )
    BEGIN
        RAISERROR ('Selected currency is not active', 16, 1)
        RETURN
    END

    -- Check if bean is active
    IF NOT EXISTS (
        SELECT 1 FROM Beans
        WHERE BeanID = @BeanID
        AND IsActive = 1
    )
    BEGIN
        RAISERROR ('Selected bean is not active', 16, 1)
        RETURN
    END

    BEGIN TRY
        BEGIN TRANSACTION
        -- For buy orders, lock funds
        IF @OrderTypeId = 1
        BEGIN
            DECLARE @Total MONEY
            SET @Total = CAST(@Quantity AS MONEY) * @PricePerBean
            EXEC LockUserFunds @UserID, @CurrencyCodeId, @Total
        END
        -- For sell orders, lock inventory
        ELSE
        BEGIN
            EXEC LockUserInventory @UserID, @BeanID, @Quantity
        END

        -- Insert the order
        INSERT INTO Orders (
            UserID, BeanID, CurrencyCodeId, OrderTypeId, StatusId,
            PricePerBean, Quantity, RemainingQuantity, OrderDate
        )
        SELECT 
            UserID, BeanID, CurrencyCodeId, OrderTypeId, 1,
            PricePerBean, Quantity, Quantity, GETUTCDATE()
        FROM inserted

        COMMIT
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR (@ErrorMessage, 16, 1)
    END CATCH
END
GO