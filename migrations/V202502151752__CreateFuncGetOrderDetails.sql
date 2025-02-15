IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[dbo].[GetOrderDetails]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [dbo].[GetOrderDetails]
GO 

CREATE OR ALTER FUNCTION GetOrderDetails(
    @OrderID BIGINT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        OrderID,
        UserID,
        BeanID,
        OrderTypeId,
        CurrencyCodeId,
        PricePerBean,
        RemainingQuantity,
        StatusId
    FROM Orders
    WHERE OrderID = @OrderID
)
GO