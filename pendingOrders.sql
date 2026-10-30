use EcommerceDB;
GO

SELECT 
    o.OrderNumber, 
    o.orderDate, 
    c.Username    AS CustomerName, 
    p.Amount      AS TotalPaid, 
    s.ShippingStatus
FROM Orders o
JOIN Customer c  ON o.customerID  = c.customerID
JOIN Payment p   ON p.OrderNumber = o.OrderNumber
JOIN Shipment s  ON s.OrderNumber = o.OrderNumber
WHERE o.[status] = 'Processing';