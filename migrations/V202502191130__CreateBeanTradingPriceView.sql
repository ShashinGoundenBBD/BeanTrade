IF OBJECT_ID('dbo.vw_beanTradingPriceView', 'V') IS NOT NULL  
    DROP VIEW [dbo].vw_beanTradingPriceView;  
GO

CREATE VIEW [dbo].vw_beanTradingPriceView AS
SELECT Beans.[Name], Beans.[Symbol],
	   Orders.PricePerBean, Trades.CreatedAt
FROM Trades
JOIN Orders
ON Trades.SellOrderID = Orders.OrderID
JOIN Beans
ON Orders.BeanID = Beans.BeanID;