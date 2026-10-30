USE EcommerceDB
GO
-----------------------------------------------Functions file----------------------------------------------------------
/* these where the functions implemented in the EcommenceDB system:
   1- GetCustomerByEmail
   2- GetCustomerOrderHistory
   3- GetOrderDetails
   4- GetOrdersByStatus
   5- GetPaymentStatus
   6- GetProductsByCategory
   7- GetReviewsByProduct
   8- GetTopRatedProducts

   9- CalculateOrderTotal
   10-CalculateShippingCost
   11-CalculateTax
   12-GetAverageRating 
   13-GetEstimateDeliveryDate
  */

-- GetCustomerByEmail
CREATE FUNCTION GetCustomerByEmail (@email VARCHAR(150))
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Customer
    WHERE Email = @email
);
GO
 

-- GetCustomerOrderHistory
CREATE FUNCTION GetCustomerOrderHistory (@customer_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Orders
    WHERE customerID = @customer_id
);
GO

-- GetOrderDetails
CREATE OR ALTER FUNCTION GetOrderDetails (@OrderID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        o.OrderNumber,
        o.orderDate,
        o.[status],
        c.Username AS CustomerName,
        pr.Name AS ProductName,
        op.Quantity_each_product AS Quantity,
        pr.Price AS UnitPrice,
        op.Quantity_each_product * pr.Price AS LineTotal
    FROM Orders o
    JOIN Customer     c  ON o.customerID  = c.customerID
    JOIN Order_Product op ON o.OrderNumber = op.OrderNumber
    JOIN Product      pr ON op.ProductID  = pr.ProductID
    WHERE o.OrderNumber = @OrderID
);
GO


-- GetOrdersByStatus
CREATE OR ALTER FUNCTION GetOrdersByStatus (@Status VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        o.OrderNumber,
        o.orderDate,
        o.[status],
        c.Username  AS CustomerName,
        p.Amount    AS TotalPaid
    FROM Orders o
    JOIN Customer c ON o.customerID  = c.customerID
    JOIN Payment  p ON p.OrderNumber = o.OrderNumber
    WHERE o.[status] = @Status
);
GO


-- GetPaymentStatus
CREATE FUNCTION dbo.GetPaymentStatus
	(@OrderNumber INT)
RETURNS TABLE
AS
RETURN
(
	SELECT
		p.paymentID,
		p.[Date]   AS PaymentDate,
		p.[Status] AS PaymentStatus,
		p.Amount,
		p.Method,
		p.OrderNumber,
		o.[status] AS OrderStatus
	FROM Payment p
	JOIN Orders  o ON p.OrderNumber = o.OrderNumber
	WHERE p.OrderNumber = @OrderNumber
);
GO


-- GetProductsByCategory
CREATE FUNCTION GetProductsByCategory (@CategoryName VARCHAR(100))
RETURNS TABLE
AS
RETURN (
    SELECT 
        Product.ProductID,
        Product.Name AS ProductName,
        Product.Price,
        Product.stockQuantity,
        ProductCategory.Name AS Category
    FROM Product
    JOIN ProductCategory 
        ON Product.categoryID = ProductCategory.categoryID
    WHERE ProductCategory.Name = @CategoryName
      AND Product.stockQuantity > 0
);
GO

-- GetReviewsByProduct
CREATE FUNCTION dbo.GetReviewsByProduct
	(@ProductID INT)
RETURNS TABLE
AS
RETURN
(
	SELECT
		r.ReviewID,
		c.Username,
		r.Rate,
		r.Comment,
		p.Name AS ProductName
	FROM Review   r
	JOIN Customer c ON r.customerID = c.customerID
	JOIN Product  p ON r.ProductID  = p.ProductID
	WHERE r.ProductID = @ProductID
);
GO


-- GetTopRatedProducts
CREATE FUNCTION dbo.GetTopRatedProducts
	(@Limit INT)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP(@Limit)
		p.ProductID,
		p.Name                                       AS ProductName,
		p.Price,
		p.stockQuantity,
		pc.Name                                      AS Category,
		COUNT(r.ReviewID)                            AS TotalReviews,
		ROUND(AVG(CAST(r.Rate AS DECIMAL(3,2))), 2) AS AverageRating
	FROM Product         p
	JOIN ProductCategory pc ON p.categoryID = pc.categoryID
	LEFT JOIN Review     r  ON p.ProductID  = r.ProductID
	GROUP BY p.ProductID, p.Name, p.Price, p.stockQuantity, pc.Name
	HAVING COUNT(r.ReviewID) > 0
	ORDER BY AverageRating DESC, TotalReviews DESC
);
GO



-- CalculateOrderTotal
CREATE OR ALTER FUNCTION CalculateOrderTotal (@OrderID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Subtotal DECIMAL(10,2);
    DECLARE @Tax      DECIMAL(10,2);
    DECLARE @Shipping DECIMAL(10,2) = 50.00; -- flat shipping fee

    SELECT @Subtotal = SUM(op.Quantity_each_product * p.Price)
    FROM Order_Product op
    JOIN Product p ON op.ProductID = p.ProductID
    WHERE op.OrderNumber = @OrderID;

    SET @Subtotal = ISNULL(@Subtotal, 0);
    SET @Tax      = @Subtotal * 0.14; -- 14% VAT

    RETURN @Subtotal + @Tax + @Shipping;
END;
GO

--CalculateShippingCost
CREATE FUNCTION dbo.CalculateShippingCost
	(@WeightKg    DECIMAL(6,2),
	 @Destination VARCHAR(100),
	 @Method      VARCHAR(50))
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @BaseFee       DECIMAL(10,2);
	DECLARE @PerKgRate     DECIMAL(10,2);
	DECLARE @DestSurcharge DECIMAL(10,2);
	DECLARE @ShippingCost  DECIMAL(10,2);
	DECLARE @MethodUpper   VARCHAR(50);
	DECLARE @DestUpper     VARCHAR(100);

	SELECT @MethodUpper = UPPER(LTRIM(RTRIM(@Method)));
	SELECT @DestUpper   = UPPER(LTRIM(RTRIM(@Destination)));
	SET @DestSurcharge  = 0;

	IF @MethodUpper = 'STANDARD'
	BEGIN
		SET @BaseFee   = 20;
		SET @PerKgRate = 5;
	END
	ELSE IF @MethodUpper = 'EXPRESS'
	BEGIN
		SET @BaseFee   = 40;
		SET @PerKgRate = 10;
	END
	ELSE IF @MethodUpper = 'OVERNIGHT'
	BEGIN
		SET @BaseFee   = 80;
		SET @PerKgRate = 20;
	END
	ELSE
	BEGIN
		SET @BaseFee   = 20;
		SET @PerKgRate = 5;
	END

	IF @DestUpper NOT IN ('CAIRO', 'GIZA')
		SET @DestSurcharge = 15;

	SELECT @ShippingCost = ROUND(@BaseFee + (@WeightKg * @PerKgRate) + @DestSurcharge, 2);

	RETURN @ShippingCost;
END;
GO

--CalculateTax
CREATE FUNCTION dbo.CalculateTax
	(@Subtotal DECIMAL(10,2),
	 @Region   VARCHAR(100))
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @TaxRate     DECIMAL(5,2);
	DECLARE @TaxAmount   DECIMAL(10,2);
	DECLARE @RegionUpper VARCHAR(100);

	SELECT @RegionUpper = UPPER(LTRIM(RTRIM(@Region)));

	IF @RegionUpper IN ('CAIRO', 'GIZA')
		SET @TaxRate = 0.14;
	ELSE IF @RegionUpper = 'ALEXANDRIA'
		SET @TaxRate = 0.12;
	ELSE IF @RegionUpper IN ('MANSOURA', 'TANTA')
		SET @TaxRate = 0.10;
	ELSE
		SET @TaxRate = 0.08;

	SELECT @TaxAmount = ROUND(@Subtotal * @TaxRate, 2);

	RETURN @TaxAmount;
END;
GO

--GetAverageRating 
CREATE FUNCTION dbo.GetAverageRating
	(@ProductID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
	DECLARE @AvgRating DECIMAL(3,2);

	SELECT @AvgRating = ROUND(AVG(CAST(Rate AS DECIMAL(3,2))), 2)
	FROM Review
	WHERE ProductID = @ProductID;

	IF @AvgRating IS NULL
		SET @AvgRating = 0;

	RETURN @AvgRating;
END;
GO


--GetEstimateDeliveryDate
CREATE FUNCTION dbo.GetEstimatedDeliveryDate
	(@OrderNumber INT)
RETURNS DATE
AS
BEGIN
	DECLARE @ETA            DATE;
	DECLARE @ShippingStatus VARCHAR(50);
	DECLARE @PickupDate     DATE;
	DECLARE @DeliveryDate   DATE;
	DECLARE @Today          DATE;

	SELECT
		@ShippingStatus = ShippingStatus,
		@PickupDate     = PickupDate,
		@DeliveryDate   = DeliveryDate
	FROM Shipment
	WHERE OrderNumber = @OrderNumber;

	SELECT @Today = CAST(GETDATE() AS DATE);

	IF @ShippingStatus IS NULL
		RETURN NULL;

	IF @ShippingStatus = 'Delivered'
		SET @ETA = @DeliveryDate;

	ELSE IF @ShippingStatus = 'Cancelled'
		SET @ETA = NULL;

	ELSE IF @ShippingStatus = 'In Transit' AND @PickupDate IS NOT NULL
		SET @ETA = DATEADD(DAY, 3, @PickupDate);

	ELSE
		SET @ETA = DATEADD(DAY, 5, @Today);

	RETURN @ETA;
END;
GO
