USE EcommerceDB
GO
-----------------------------------------------Procedures file----------------------------------------------------------
/* these where the Procedures implemented in the EcommenceDB system:
   1- AddOrUpdateCartItem
   2- AddProduct
   3- AddProductReview
   4- AssignShipment
   5- AuthenticateCustomer
   6- CancelOrder
   7- GetAllInStockproducts
   8- GetCartDetails
   9- GetOrCreateCart
   10-GetProductCatlogPage
   11-PlaceOrder
   12-ProcessPayment
   13-RegisteerCustomer
   14-RemoveCartItem
   15-UpdateCustomerProfile
   16-UpdateOrderStatus
   17-UpdateTrackingStatus
  */

-- AddOrUpdateCartItem
CREATE OR ALTER PROCEDURE AddOrUpdateCartItem
@CartID INT,
@ProductID INT,
@QuantityToAdd INT
AS
BEGIN
   -- Merge: Updates quantity if it exists, inserts if it doesn't
MERGE Cart_Product AS target
USING (SELECT @CartID AS CartID, @ProductID AS ProductID, @QuantityToAdd AS Qty) AS source
ON target.CartID = source.CartID AND target.ProductID = source.ProductID

WHEN MATCHED THEN 
UPDATE SET NoOfProducts = target.NoOfProducts + source.Qty

WHEN NOT MATCHED THEN 
INSERT (CartID, ProductID, NoOfProducts) 
VALUES (source.CartID, source.ProductID, source.Qty);

   -- Automatically recalculate and update the Cart total in the same trip
UPDATE Cart
SET totalPrice = (
SELECT ISNULL(SUM(cp.NoOfProducts * p.Price), 0)
FROM Cart_Product cp
JOIN Product p ON cp.ProductID = p.ProductID
WHERE cp.CartID = @CartID
)
WHERE CartID = @CartID;
END;


-- AddProduct
CREATE OR ALTER PROCEDURE AddProduct
    @name VARCHAR(150),
    @categoryID INT,
    @price DECIMAL(10,2),
    @stock_qty INT,
    @description TEXT
AS
BEGIN
    INSERT INTO Product (Name, categoryID, Price, stockQuantity, Description_P)
    VALUES (@name, @categoryID, @price, @stock_qty, @description);
END;
GO

   
-- AddProductReview
CREATE OR ALTER PROCEDURE AddProductReview
    @customer_id INT,
    @product_id INT,
    @rating INT,
    @comment TEXT
AS
BEGIN
    INSERT INTO Review (Comment, Rate, customerID, productID)
    VALUES (@comment, @rating, @customer_id, @product_id);
END;
GO


-- AssignShipment
CREATE OR ALTER PROCEDURE AssignShipment
    @OrderID        INT,
    @TrackingNumber VARCHAR(100)
AS
BEGIN
    -- Update the Shipment linked to this order
    UPDATE Shipment
    SET TrackingID     = @TrackingNumber,
        ShippingStatus = 'Shipped',
        PickupDate     = GETDATE()
    WHERE OrderNumber = @OrderID;

    -- Update order status
    UPDATE Orders
    SET [status] = 'Shipped'
    WHERE OrderNumber = @OrderID;
END;
GO
USE EcommerceDB;
GO


-- AuthenticateCustomer
CREATE OR ALTER PROCEDURE AuthenticateCustomer
    @Username VARCHAR(100),
    @Password VARCHAR(255)
AS
BEGIN
    SELECT customerID AS UserID, Username, Email 
    FROM Customer 
    WHERE Username = @Username AND [Password] = @Password;
END;


-- CancelOrder
CREATE OR ALTER PROCEDURE CancelOrder
    @OrderID INT
AS
BEGIN
    -- Restore stock for each product in the order
    UPDATE Product
    SET stockQuantity = stockQuantity + op.Quantity_each_product
    FROM Product
    JOIN Order_Product op ON Product.ProductID = op.ProductID
    WHERE op.OrderNumber = @OrderID;

    -- Update order status
    UPDATE Orders
    SET [status] = 'Cancelled'
    WHERE OrderNumber = @OrderID;
END;
GO



-- GetAllInStockproducts
CREATE OR ALTER PROCEDURE GetAllInStockProducts
AS
BEGIN
    SELECT 
        p.ProductID, 
        p.Name AS ProductName, 
        p.Price, 
        p.stockQuantity,
        pc.Name AS Category
    FROM Product p
    JOIN ProductCategory pc ON p.categoryID = pc.categoryID
    WHERE p.stockQuantity > 0
    ORDER BY p.ProductID;
END;



-- GetCartDetails
CREATE OR ALTER PROCEDURE GetCartDetails
    @CartID INT
AS
BEGIN
    SELECT 
        cp.ProductID,
        p.Name AS ProductName,
        p.Price AS UnitPrice,
        cp.NoOfProducts AS Quantity,
        (p.Price * cp.NoOfProducts) AS LineTotal
    FROM Cart_Product cp
    JOIN Product p ON cp.ProductID = p.ProductID
    WHERE cp.CartID = @CartID;
END;



-- GetOrCreateCart
CREATE OR ALTER PROCEDURE GetOrCreateCart
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




--GetProductCatlogPage
CREATE OR ALTER PROCEDURE GetProductCatalogPage
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


-- PlaceOrder
CREATE OR ALTER PROCEDURE PlaceOrder
    @CustomerID INT,
    @CartID     INT
AS
BEGIN
    -- Create order
    INSERT INTO Orders (orderDate, [status], customerID)
    VALUES (GETDATE(), 'Pending', @CustomerID);

    -- Get latest order ID
    DECLARE @OrderID INT;
    SET @OrderID = SCOPE_IDENTITY();  -- safer than MAX(OrderNumber)

    -- Copy cart items to order
    INSERT INTO Order_Product (OrderNumber, ProductID, Quantity_each_product)
    SELECT @OrderID, ProductID, NoOfProducts
    FROM Cart_Product
    WHERE CartID = @CartID;

    -- Reduce stock
    UPDATE Product
    SET stockQuantity = stockQuantity - cp.NoOfProducts
    FROM Product
    JOIN Cart_Product cp ON Product.ProductID = cp.ProductID
    WHERE cp.CartID = @CartID;

    -- Clear cart
    DELETE FROM Cart_Product
    WHERE CartID = @CartID;

    -- Reset cart total
    UPDATE Cart
    SET totalPrice = 0
    WHERE CartID = @CartID;

    -- Return order ID
    SELECT @OrderID AS OrderID;
END;
GO


-- ProcessPayment
CREATE PROCEDURE ProcessPayment
	(@OrderNumber INT,
	 @Method      VARCHAR(50),
	 @Amount      DECIMAL(10,2))
AS
BEGIN
	DECLARE @OrderStatus VARCHAR(50);

	IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderNumber = @OrderNumber)
	BEGIN
		RAISERROR('Order #%d does not exist.', 16, 1, @OrderNumber);
		RETURN;
	END

	IF EXISTS (
		SELECT 1 FROM Payment
		WHERE OrderNumber = @OrderNumber
		  AND [Status] = 'Completed'
	)
	BEGIN
		RAISERROR('Order #%d already has a completed payment.', 16, 1, @OrderNumber);
		RETURN;
	END

	INSERT INTO Payment ([Date], [Status], Amount, Method, OrderNumber)
	VALUES (CAST(GETDATE() AS DATE), 'Completed', @Amount, @Method, @OrderNumber);

	SELECT @OrderStatus = [status] FROM Orders WHERE OrderNumber = @OrderNumber;

	IF @OrderStatus NOT IN ('Delivered', 'Cancelled')
	BEGIN
		UPDATE Orders
		SET [status] = 'Processing'
		WHERE OrderNumber = @OrderNumber;
	END

	PRINT 'Payment processed successfully for Order #' + CAST(@OrderNumber AS VARCHAR(20));
END;
GO


-- RegisterCustomer
CREATE OR ALTER PROCEDURE RegisterCustomer
    @name VARCHAR(100),
    @email VARCHAR(150),
    @password VARCHAR(255),
    @phone NVARCHAR(10)
AS
BEGIN
    INSERT INTO Customer (Username, Email, [Password], PhoneNumber)
    VALUES (@name, @email, @password, @phone);
END;
GO

--RemoveCartItem
CREATE OR ALTER PROCEDURE RemoveCartItem
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



-- UpdateCustomerProfile
CREATE OR ALTER PROCEDURE UpdateCustomerProfile
    @customer_id INT,
    @new_email VARCHAR(150),
    @new_city VARCHAR(100),
    @new_street VARCHAR(150),
    @new_buildingNo INT,
    @new_apartmentNo INT = NULL
AS
BEGIN
    -- Update email
    UPDATE Customer
    SET Email = @new_email
    WHERE customerID = @customer_id;

    -- Update address
    UPDATE Customer_Address
    SET city = @new_city,
        street = @new_street,
        buildingNo = @new_buildingNo,
        apartmentNo = @new_apartmentNo
    WHERE customerID = @customer_id;
END;
GO



--UpdateOrderStatus
CREATE OR ALTER PROCEDURE UpdateOrderStatus
    @OrderID    INT,
    @NewStatus  VARCHAR(50)
AS
BEGIN
    
    DECLARE @CurrentStatus VARCHAR(50);
    SELECT @CurrentStatus = [status] FROM Orders WHERE OrderNumber = @OrderID;

    IF (@CurrentStatus = 'Pending'   AND @NewStatus = 'Shipped')   OR
       (@CurrentStatus = 'Shipped'   AND @NewStatus = 'Delivered') OR
       (@CurrentStatus = 'Pending'   AND @NewStatus = 'Cancelled')
    BEGIN
        UPDATE Orders
        SET [status] = @NewStatus
        WHERE OrderNumber = @OrderID;

        -- Update shipment status as well
        UPDATE Shipment
        SET ShippingStatus = @NewStatus,
            PickupDate     = CASE WHEN @NewStatus = 'Shipped'   THEN GETDATE() ELSE PickupDate   END,
            DeliveryDate   = CASE WHEN @NewStatus = 'Delivered' THEN GETDATE() ELSE DeliveryDate END
        WHERE OrderNumber = @OrderID;
    END
    ELSE
        PRINT 'Invalid status transition from ' + @CurrentStatus + ' to ' + @NewStatus;
END;
GO



-- UpdateTrackingStatus
CREATE OR ALTER PROCEDURE UpdateTrackingStatus
    @TrackingNumber VARCHAR(100),
    @Status         VARCHAR(50)
AS
BEGIN
    UPDATE Shipment
    SET ShippingStatus = @Status,
        PickupDate     = CASE WHEN @Status = 'Shipped'   THEN GETDATE() ELSE PickupDate   END,
        DeliveryDate   = CASE WHEN @Status = 'Delivered' THEN GETDATE() ELSE DeliveryDate END
    WHERE TrackingID = @TrackingNumber;
END;
GO
