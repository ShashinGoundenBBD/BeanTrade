IF OBJECT_ID('dbo.vw_UserPortfolio', 'V') IS NOT NULL  
    DROP VIEW [dbo].vw_UserPortfolio;  
GO

CREATE VIEW [dbo].vw_UserPortfolio AS
SELECT
    u.UserID,
    u.UserGuid,
    u.IsActive,
    
    wc.CurrencyCode,
    w.Balance AS WalletBalance,
    
    b.Symbol AS BeanSymbol,
    i.Quantity AS BeanQuantity

FROM dbo.Users u

LEFT JOIN dbo.Wallets w
    ON u.UserID = w.UserID
LEFT JOIN dbo.CurrencyCodes wc
    ON w.CurrencyCodeId = wc.CurrencyCodeId

LEFT JOIN dbo.Inventory i
    ON u.UserID = i.UserID
LEFT JOIN dbo.Beans b
    ON i.BeanID = b.BeanID

LEFT JOIN dbo.Orders o
    ON i.BeanID = o.BeanID AND o.StatusId = (SELECT StatusId FROM dbo.OrderStatuses WHERE Status = 'OPEN') 
    AND o.OrderTypeId = (SELECT OrderTypeId FROM dbo.OrderTypes WHERE OrderType = 'Buy')

WHERE u.IsActive = 1 AND WalletID IS NOT NULL;