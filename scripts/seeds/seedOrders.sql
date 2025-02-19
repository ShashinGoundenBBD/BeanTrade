-- Create buy orders in Rand markets
EXEC dbo.CreateBuyOrder @UserId = 1, @PricePerBean = 25, @BeanID = 1, @CurrencyCodeID = 1, @quantity = 100;   -- User 1 buying Arabica at R25
GO 

EXEC dbo.CreateBuyOrder @UserId = 2, @PricePerBean = 15, @BeanID = 2, @CurrencyCodeID = 1, @quantity = 150; -- User 2 buying Robusta at R15
GO 

EXEC dbo.CreateBuyOrder @UserId = 3, @PricePerBean = 45, @BeanID = 3, @CurrencyCodeID = 1, @quantity = 80; -- User 3 buying Kona at R45
GO 
 
---- Create matching sell orders in Rand markets
EXEC dbo.CreateSellOrder @UserId = 61, @PricePerBean = 25, @BeanID = 1, @CurrencyCodeID = 1, @quantity = 100;   -- User 61 selling Arabica at R25
GO 

EXEC dbo.CreateSellOrder @UserId = 71, @PricePerBean = 15, @BeanID = 2, @CurrencyCodeID = 1, @quantity = 150; -- User 71 selling Robusta at R15
GO 

EXEC dbo.CreateSellOrder @UserId = 81, @PricePerBean = 45, @BeanID = 3, @CurrencyCodeID = 1, @quantity = 80; -- User 81 selling Kona at R45
GO 

-- Create buy orders in USD market
EXEC dbo.CreateBuyOrder @UserId = 21, @PricePerBean = 22, @BeanID = 1, @CurrencyCodeID = 2, @quantity = 120;   -- User 21 buying Arabica at  $22
GO 

EXEC dbo.CreateBuyOrder @UserId = 22, @PricePerBean = 13, @BeanID = 2, @CurrencyCodeID = 2, @quantity = 130; -- User 22 buying Robusta at $13
GO 

---- Create matching sell orders in USD market
EXEC dbo.CreateSellOrder @UserId = 62, @PricePerBean = 22, @BeanID = 1, @CurrencyCodeID = 2, @quantity = 120;   -- User 62 selling Arabica at $22
GO 

EXEC dbo.CreateSellOrder @UserId = 72, @PricePerBean = 13, @BeanID = 2, @CurrencyCodeID = 2, @quantity = 130; -- User 72 selling Robusta at €13
GO

---- Create buy orders in EURO market
EXEC dbo.CreateBuyOrder @UserId = 41, @PricePerBean = 12, @BeanID = 2, @CurrencyCodeID = 3, @quantity = 110;   -- User 41 buying Robusta at €12
GO 

EXEC dbo.CreateBuyOrder @UserId = 42, @PricePerBean = 40, @BeanID = 3, @CurrencyCodeID = 3, @quantity = 90; -- User 42 buying Kona at €40
GO 

---- Create matching sell orders in EURO market
EXEC dbo.CreateSellOrder @UserId = 73, @PricePerBean = 12, @BeanID = 2, @CurrencyCodeID = 3, @quantity = 110;   -- User 73 selling Robusta at €12
GO

EXEC dbo.CreateSellOrder @UserId = 82, @PricePerBean = 40, @BeanID = 3, @CurrencyCodeID = 3, @quantity = 90; -- User 82 selling Kona at €40
GO
