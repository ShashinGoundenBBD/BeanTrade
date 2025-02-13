-- Create some active orders
INSERT INTO Orders (UserID, BeanID, CurrencyCodeId, OrderTypeId, StatusId, PricePerBean, Quantity, RemainingQuantity)
VALUES 
	  (1, 2, 1, 1, 1, 5.00, 200, 200);    -- User 1 wants to buy 200 Robusta at $5 each
GO