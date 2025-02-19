IF OBJECT_ID('dbo.vw_TradeHistory', 'V') IS NOT NULL  
    DROP VIEW [dbo].vw_TradeHistory;  
GO

CREATE VIEW [dbo].vw_TradeHistory AS
SELECT
	TradeID,
	UserGuid AS BuyerID,
	UserGuid AS SellerID,
	Trades.[Quantity],
	PricePerBean AS BuyPricePB,
	PricePerBean AS SellPricePB,
	CurrencyCode,
	Symbol AS BeanSymbol,
	(Trades.[Quantity] * PricePerBean) AS Total,
	DATEDIFF(day, Orders.[OrderDate], Trades.[CreatedAt]) As [Time to Fulfull]
FROM Trades 
JOIN Orders
	ON Trades.BuyOrderID = Orders.OrderID
JOIN Users
	ON  Orders.UserID = Users.UserID
JOIN CurrencyCodes 
	ON Orders.CurrencyCodeId = CurrencyCodes.CurrencyCodeId
JOIN Beans 
	ON Orders.BeanID = Beans.BeanID;
	


