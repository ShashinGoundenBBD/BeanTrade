
CREATE OR ALTER VIEW vw_InventoryBalance AS
SELECT 
    u.UserID,
    u.UserGuid,
    i.LockedQuantity,
    i.AvailableQuantity,
	b.Symbol,
    (i.LockedQuantity + i.AvailableQuantity) AS TotalInventory
FROM 
    Inventory i
INNER JOIN 
    Users u ON i.UserID = u.UserID
INNER JOIN Beans b ON b.BeanId = i.BeanID
WHERE 
    u.IsActive = 1 AND b.IsActive = 1
GO