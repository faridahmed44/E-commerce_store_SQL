CREATE PROCEDURE AddOrUpdateCartItem
    @CartID INT,
    @ProductID INT,
    @QuantityToAdd INT
AS
BEGIN
    -- 1. Merge: Updates quantity if it exists, inserts if it doesn't
    MERGE Cart_Product AS target
    USING (SELECT @CartID AS CartID, @ProductID AS ProductID, @QuantityToAdd AS Qty) AS source
    ON target.CartID = source.CartID AND target.ProductID = source.ProductID
    
    WHEN MATCHED THEN 
        UPDATE SET NoOfProducts = target.NoOfProducts + source.Qty
        
    WHEN NOT MATCHED THEN 
        INSERT (CartID, ProductID, NoOfProducts) 
        VALUES (source.CartID, source.ProductID, source.Qty);

    -- 2. Automatically recalculate and update the Cart total in the same trip
    UPDATE Cart
    SET totalPrice = (
        SELECT ISNULL(SUM(cp.NoOfProducts * p.Price), 0)
        FROM Cart_Product cp
        JOIN Product p ON cp.ProductID = p.ProductID
        WHERE cp.CartID = @CartID
    )
    WHERE CartID = @CartID;
END;