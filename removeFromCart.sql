
use EcommerceDB;
GO

CREATE PROCEDURE RemoveCartItem
    @CartID INT,
    @ProductID INT
AS
BEGIN
    -- 1. Remove the specific product from the cart
    DELETE FROM Cart_Product 
    WHERE CartID = @CartID AND ProductID = @ProductID;

    -- 2. Recalculate and update the Cart total in the same trip
    UPDATE Cart
    SET totalPrice = (
        SELECT ISNULL(SUM(cp.NoOfProducts * p.Price), 0)
        FROM Cart_Product cp
        JOIN Product p ON cp.ProductID = p.ProductID
        WHERE cp.CartID = @CartID
    )
    WHERE CartID = @CartID;
END;