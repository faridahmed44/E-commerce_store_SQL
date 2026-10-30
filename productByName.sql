SELECT ProductID, Name, Price, stockQuantity 
FROM Product 
WHERE Name LIKE @SearchTerm;