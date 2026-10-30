CREATE PROCEDURE GetProductCatalogPage
    @PageNumber INT,
    @RowsPerPage INT
AS
BEGIN
    SELECT 
        p.ProductID, 
        p.Name AS ProductName, 
        p.Price, 
        pc.Name AS Category
    FROM Product p
    JOIN ProductCategory pc ON p.categoryID = pc.categoryID
    WHERE p.stockQuantity > 0
    ORDER BY p.ProductID 
    OFFSET (@PageNumber - 1) * @RowsPerPage ROWS
    FETCH NEXT @RowsPerPage ROWS ONLY;
END;