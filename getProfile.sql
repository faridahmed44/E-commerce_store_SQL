SELECT 
    c.Username, 
    c.Email, 
    c.PhoneNumber, 
    ca.city, 
    ca.street, 
    ca.buildingNo, 
    ca.apartmentNo
FROM Customer c
LEFT JOIN Customer_Address ca ON c.customerID = ca.customerID
WHERE c.customerID = @CustomerID;