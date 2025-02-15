IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[ExpireOrders]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[ExpireOrders]
END
GO


-- Add helper procedure to expire orders
CREATE OR ALTER PROCEDURE ExpireOrders
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Orders
    SET StatusId = 4  -- Expired
    WHERE StatusId = 1  -- Active
    AND ExpiryDate IS NOT NULL
    AND ExpiryDate < GETUTCDATE();
END;
GO