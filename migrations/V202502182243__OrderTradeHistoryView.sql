IF OBJECT_ID('dbo.vw_Order_History', 'V') IS NOT NULL  
    DROP VIEW [dbo].vw_Order_Historye;  
GO

SELECT OrderId, UserGuid, WalletGuid, 
		CASE WHEN Users.IsActive = 1 THEN 'Active' WHEN Users.IsActive = 0 THEN 'Inactive' END AS UserState, 
		Beans.[Name] AS BeanName, 
        CASE WHEN Beans.IsActive = 1 THEN 'Active' WHEN Beans.IsActive = 0 THEN 'Inactive' END AS BeanState, 
		CurrencyCode, CurrencyCodes.[Name] AS CurrencyName, 
        CASE WHEN CurrencyCodes.IsActive = 1 THEN 'Active' WHEN CurrencyCodes.IsActive = 0 THEN 'Inactive' END AS CurrencyCodeState, 
		OrderType, OrderStatuses.[Status], 
        PricePerBean, Quantity, RemainingQuantity, OrderDate, ExpiryDate
FROM Orders
JOIN Users
ON Orders.UserID = Users.UserID
JOIN Wallets
ON Users.UserId = Wallets.UserID
JOIN Beans
ON Orders.BeanID = Beans.BeanID
JOIN CurrencyCodes
ON Orders.CurrencyCodeId = CurrencyCodes.CurrencyCodeId
JOIN OrderTypes
ON Orders.OrderTypeId = OrderTypes.OrderTypeId
JOIN OrderStatuses
ON Orders.StatusId = OrderStatuses.StatusId

