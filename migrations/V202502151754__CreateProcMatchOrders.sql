IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[MatchOrders]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[MatchOrders]
END

CREATE OR ALTER PROCEDURE MatchOrders
    @OrderID BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BeanID INT, @OrderTypeId INT, @PricePerBean MONEY, @RemainingQuantity INT,
            @UserID INT, @CurrencyCodeId INT

    -- Get order details using function made
    SELECT 
        @BeanID = BeanID,
        @OrderTypeId = OrderTypeId,
        @PricePerBean = PricePerBean,
        @RemainingQuantity = RemainingQuantity,
        @UserID = UserID,
        @CurrencyCodeId = CurrencyCodeId
    FROM GetOrderDetails(@OrderID)

    -- If order is already complete
    IF @RemainingQuantity = 0
        RETURN

    -- Find matching orders
    DECLARE @MatchedOrders TABLE (
        OrderID BIGINT,
        MatchQuantity INT,
        PricePerBean MONEY,
        RowNum INT
    )

    IF @OrderTypeId = 1 -- Buy Order, conditions <= 
    BEGIN
        INSERT INTO @MatchedOrders
        SELECT 
            o.OrderID,
            CASE --- Logic for checking what the quanity matched would be 
                WHEN o.RemainingQuantity <= @RemainingQuantity 
                THEN o.RemainingQuantity 
                ELSE @RemainingQuantity 
            END as MatchQuantity,
            o.PricePerBean,
            ROW_NUMBER() OVER (ORDER BY o.PricePerBean ASC, o.OrderDate ASC) as RowNum
        FROM Orders o
        WHERE o.BeanID = @BeanID
            AND o.OrderTypeId = 2 -- Sell orders
            AND o.StatusId = 1 -- Active
            AND o.CurrencyCodeId = @CurrencyCodeId -- Match same currency only
            AND o.PricePerBean <= @PricePerBean -- less than or equal to our buy price
            AND o.OrderID != @OrderID
            AND o.UserID != @UserID
    END
    ELSE -- Sell Order
    BEGIN
        INSERT INTO @MatchedOrders
        SELECT 
            o.OrderID,
            CASE --- same logic as above for quantity matching
                WHEN o.RemainingQuantity <= @RemainingQuantity 
                THEN o.RemainingQuantity 
                ELSE @RemainingQuantity 
            END as MatchQuantity,
            o.PricePerBean,
            ROW_NUMBER() OVER (ORDER BY o.PricePerBean DESC, o.OrderDate ASC) as RowNum
        FROM Orders o
        WHERE o.BeanID = @BeanID
            AND o.OrderTypeId = 1 -- Buy orders
            AND o.StatusId = 1 -- Active
            AND o.CurrencyCodeId = @CurrencyCodeId -- Match same currency only
            AND o.PricePerBean >= @PricePerBean -- need buys >= to our sell
            AND o.OrderID != @OrderID
            AND o.UserID != @UserID
    END

    -- Process each match
    DECLARE @CurrentMatch BIGINT, @MatchQuantity INT, @MatchPrice MONEY
    DECLARE @LocalBuyOrderID BIGINT, @LocalSellOrderID BIGINT

    --- Make use of cursor so you can go through multiple matches "e.g think of 3 partial can do it all once"
    DECLARE @MatchCursor CURSOR

    SET @MatchCursor = CURSOR FOR
    SELECT OrderID, MatchQuantity, PricePerBean
    FROM @MatchedOrders
    ORDER BY RowNum

    OPEN @MatchCursor
    FETCH NEXT FROM @MatchCursor INTO @CurrentMatch, @MatchQuantity, @MatchPrice

    WHILE @@FETCH_STATUS = 0 AND @RemainingQuantity > 0 --- We go through matches until fufilled
    BEGIN
        BEGIN TRY
            IF @OrderTypeId = 1
            BEGIN
                SET @LocalBuyOrderID = @OrderID --- need to get this information for our processtrade call
                SET @LocalSellOrderID = @CurrentMatch
            END
            ELSE
            BEGIN
                SET @LocalBuyOrderID = @CurrentMatch
                SET @LocalSellOrderID = @OrderID
            END

            -- Process the trade
            EXEC ProcessTrade @LocalBuyOrderID, @LocalSellOrderID, @MatchQuantity
            SET @RemainingQuantity = @RemainingQuantity - @MatchQuantity
            PRINT 'Successfully processed trade for OrderID: ' + CAST(@CurrentMatch AS VARCHAR(20))

        END TRY
        BEGIN CATCH
            PRINT 'Error processing trade for OrderID: ' + CAST(@CurrentMatch AS VARCHAR(20))
            PRINT ERROR_MESSAGE()
        END CATCH

        FETCH NEXT FROM @MatchCursor INTO @CurrentMatch, @MatchQuantity, @MatchPrice
    END

    CLOSE @MatchCursor
    DEALLOCATE @MatchCursor
END
GO