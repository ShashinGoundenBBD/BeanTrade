IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[CreateSellOrder]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[CreateSellOrder]
END
GO

CREATE OR ALTER PROCEDURE CreateSellOrder
    @UserId INT,
    @PricePerBean MONEY,
    @BeanID INT,
	@CurrencyCodeID INT,
	@quantity INT
AS
BEGIN
	INSERT INTO Orders (UserID, BeanID, CurrencyCodeId, OrderTypeId, StatusId, PricePerBean, Quantity, RemainingQuantity)
	VALUES (@UserId, @BeanID, @CurrencyCodeID, 2, 1, @PricePerBean, @quantity, @quantity);  
END	