IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[ProcessTrade]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[ProcessTrade]
END
GO

CREATE OR ALTER PROCEDURE ProcessTrade
    @BuyOrderID BIGINT,
    @SellOrderID BIGINT,
    @MatchedQuantity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @BuyerID INT, @SellerID INT, @BeanID INT, 
                @BuyerCurrencyId INT, @SellerCurrencyId INT,
                @BuyerPrice MONEY, @SellerPrice MONEY

        -- Get order details using the new function
        SELECT @BuyerID = UserID, @BeanID = BeanID, 
               @BuyerPrice = PricePerBean, @BuyerCurrencyId = CurrencyCodeId
        FROM GetOrderDetails(@BuyOrderID)

        SELECT @SellerID = UserID, @SellerPrice = PricePerBean, 
               @SellerCurrencyId = CurrencyCodeId
        FROM GetOrderDetails(@SellOrderID)

        -- Verify same currency
        IF @BuyerCurrencyId != @SellerCurrencyId
        BEGIN
            RAISERROR ('Currency mismatch between orders', 16, 1)
            RETURN
        END

        BEGIN TRANSACTION

        -- Create trade record
        INSERT INTO Trades (BuyOrderID, SellOrderID, Quantity)
        VALUES (@BuyOrderID, @SellOrderID, @MatchedQuantity)

        -- Update order quantities
        UPDATE Orders 
        SET RemainingQuantity = RemainingQuantity - @MatchedQuantity
        WHERE OrderID IN (@BuyOrderID, @SellOrderID)

        -- Calculate amounts
        DECLARE @BuyerAmount MONEY = @MatchedQuantity * @BuyerPrice
        DECLARE @SellerAmount MONEY = @MatchedQuantity * @SellerPrice

        -- Update buyer's wallet and inventory
        UPDATE Wallets
        SET Balance = Balance - @BuyerAmount,
            LockedBalance = LockedBalance - @BuyerAmount
        WHERE UserID = @BuyerID AND CurrencyCodeId = @BuyerCurrencyId

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK
            RAISERROR ('Failed to update buyer wallet', 16, 1)
            RETURN
        END

        -- Check if buyer already has an inventory record
        IF NOT EXISTS (SELECT 1 FROM Inventory WHERE UserID = @BuyerID AND BeanID = @BeanID)
        BEGIN
            -- Create new inventory record for buyer
            INSERT INTO Inventory (UserID, BeanID, Quantity, LockedQuantity)
            VALUES (@BuyerID, @BeanID, @MatchedQuantity, 0)
        END
        ELSE
        BEGIN
            -- Update existing inventory
            UPDATE Inventory
            SET Quantity = Quantity + @MatchedQuantity
            WHERE UserID = @BuyerID AND BeanID = @BeanID
        END

        -- Update seller's wallet and inventory
        -- Check if seller has a wallet before updating
        IF NOT EXISTS (SELECT 1 FROM Wallets WHERE UserID = @SellerID AND CurrencyCodeId = @SellerCurrencyId)
        BEGIN
            -- Create new wallet for seller
            INSERT INTO Wallets (UserID, CurrencyCodeId, Balance, LockedBalance)
            VALUES (@SellerID, @SellerCurrencyId, @SellerAmount, 0)
        END
        ELSE
        BEGIN
            -- Update existing wallet
            UPDATE Wallets
            SET Balance = Balance + @SellerAmount
            WHERE UserID = @SellerID AND CurrencyCodeId = @SellerCurrencyId
        END

        UPDATE Inventory
        SET Quantity = Quantity - @MatchedQuantity,
            LockedQuantity = LockedQuantity - @MatchedQuantity
        WHERE UserID = @SellerID AND BeanID = @BeanID

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK
            RAISERROR ('Failed to update seller inventory', 16, 1)
            RETURN
        END

        -- Create transaction records
        INSERT INTO Transactions (WalletID, TransactionTypeId, Amount, Balance)
        SELECT 
            w.WalletID, 
            1, -- Trade transaction type
            CASE WHEN w.UserID = @BuyerID THEN -@BuyerAmount ELSE @SellerAmount END,
            w.Balance
        FROM Wallets w
        WHERE w.UserID IN (@BuyerID, @SellerID)
        AND w.CurrencyCodeId IN (@BuyerCurrencyId, @SellerCurrencyId)

        COMMIT
        PRINT 'Trade processed successfully'
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK
        PRINT ERROR_MESSAGE()
    END CATCH
END
GO