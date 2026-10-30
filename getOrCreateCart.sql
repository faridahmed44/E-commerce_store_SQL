use EcommerceDB;
GO

CREATE PROCEDURE GetOrCreateCart
    @CustomerID INT
AS
BEGIN
    DECLARE @ActiveCartID INT;

    -- 1. Check if the customer already has an active cart
    SELECT @ActiveCartID = CartID 
    FROM Cart 
    WHERE customerID = @CustomerID;

    -- 2. If no cart exists, create a fresh one and grab the new ID
    IF @ActiveCartID IS NULL
    BEGIN
        INSERT INTO Cart (customerID, totalPrice)
        VALUES (@CustomerID, 0);

        -- SCOPE_IDENTITY() safely grabs the ID of the row we just inserted
        SET @ActiveCartID = SCOPE_IDENTITY();
    END

    -- 3. Return the CartID to the front-end
    SELECT @ActiveCartID AS ActiveCartID;
END;