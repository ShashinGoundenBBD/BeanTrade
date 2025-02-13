-- Create some active orders
INSERT INTO Orders (UserID, BeanID, CurrencyCodeId, OrderTypeId, StatusId, PricePerBean, Quantity, RemainingQuantity)
VALUES   
    ---- Active sell orders
    (3, 2, 1, 2, 1, 5.00, 400, 400)    -- User 3 wants to sell 400 Robusta at $5 each
GO