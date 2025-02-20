CREATE OR ALTER VIEW vw_AccountBalance AS
SELECT 
    u.UserID,
    u.UserGuid,
    wc.CurrencyCode,
    wc.Name AS CurrencyName,
    w.Balance,
    w.LockedBalance,
    (w.Balance + w.LockedBalance) AS TotalBalance
FROM 
    Wallets w
INNER JOIN 
    Users u ON w.UserID = u.UserID
INNER JOIN 
    CurrencyCodes wc ON w.CurrencyCodeId = wc.CurrencyCodeId
WHERE 
    u.IsActive = 1 
GO