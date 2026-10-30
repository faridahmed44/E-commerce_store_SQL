use EcommerceDB;
GO

INSERT INTO Customer(Username ,Email ,[Password],PhoneNumber)
values('mayOmar12' ,'may@gmail.com','may1234','01142356780'),
      ('radwaSayed8' ,'Rsayed@gmail.com','radwa1234','01142536780'),
      ('Faridahmed2' ,'Farida@gmail.com','farida1234','01133356780'),
      ('sandraWaleed44' ,'sandraW@gmail.com','sandra1234','01242356780'),
      ('ahmedshata1' ,'shata@gmail.com','shata1234','01142444780'),
      ('ferasAhmed' ,'feras@gmail.com','feras1234','01142366600')

ALTER TABLE Customer
ALTER COLUMN PhoneNumber NVARCHAR(11);

INSERT INTO Customer_Address (customerID, city, street, buildingNo, apartmentNo)
VALUES
(1, 'Cairo',       'El Tahrir Street',    12, 3),
(2, 'Alexandria',  'Corniche Road',       45, 7),
(3, 'Cairo',       'Nasr City Avenue',    8,  NULL),
(4, 'Giza',        'Haram Street',        22, 5),
(5, 'Cairo',       'Heliopolis Street',   33, 11),
(6, 'Mansoura',    'El Gomhoria Street',  17, 2);

INSERT INTO ProductCategory (Name, Description_C)
VALUES
('Electronics',     'Phones, laptops, and electronic devices'),
('Clothing',        'Men and women fashion and accessories'),
('Home Appliances', 'Kitchen and household appliances'),
('Books',           'Educational and fiction books'),
('Sports',          'Sports equipment and accessories');


INSERT INTO Product (Name, Price, stockQuantity, Description_P, categoryID) VALUES
('iPhone 15',           15999.99, 50,  'Latest Apple smartphone',         1),
('Samsung Galaxy S24',  12999.99, 40,  'Latest Samsung flagship phone',   1),
('Nike T-Shirt',          299.99, 100, 'Comfortable cotton t-shirt',      2),
('Adidas Sneakers',       899.99, 60,  'Lightweight running shoes',       2),
('Air Fryer',            1599.99, 30,  'Digital air fryer 5L capacity',   3),
('Coffee Maker',          799.99, 45,  'Automatic drip coffee maker',     3),
('The Alchemist',          89.99, 200, 'Novel by Paulo Coelho',           4),
('Clean Code Book',       199.99, 80,  'Programming best practices book', 4),
('Yoga Mat',              249.99, 70,  'Non-slip exercise yoga mat',      5),
('Football',              199.99, 90,  'Official size football',          5);

INSERT INTO Review (Comment, Rate, customerID, ProductID) VALUES
('Amazing phone, very fast!',          5, 1, 1),
('Good quality but a bit expensive',   4, 2, 2),
('Love the t-shirt, very comfortable', 5, 3, 3),
('Shoes are great for running',        4, 4, 4),
('Air fryer changed my life!',         5, 5, 5),
('Book was delivered quickly',         3, 6, 7),
('Great product overall',              4, 1, 8),
('Not what I expected',                2, 2, 10);

INSERT INTO Cart ( customerID) VALUES
(1),(2),(3),(4),(5),(6);

INSERT INTO Orders (orderDate, [status], customerID) VALUES
('2024-01-05', 'Delivered',  1),
('2024-01-08', 'Delivered',  2 ),
('2024-01-12', 'Processing', 3),
('2024-01-15', 'Delivered',  4),
('2024-01-18', 'Cancelled',  5 ),
('2024-01-20', 'Delivered',  6);

INSERT INTO Payment ([Date], [Status], Amount, Method,OrderNumber) VALUES
('2024-01-05', 'Completed', 16299.98, 'Credit Card',1),
('2024-01-08', 'Completed',  1199.98, 'Cash on Delivery',2),
('2024-01-12', 'Pending',    1799.98, 'Debit Card',3),
('2024-01-15', 'Completed',   399.98, 'Credit Card',4),
('2024-01-18', 'Failed',     2499.98, 'Credit Card',5),
('2024-01-20', 'Completed',   289.98, 'Cash on Delivery',6);

INSERT INTO Shipment (TrackingID, PickupDate, DeliveryDate, ShippingStatus ,OrderNumber) VALUES
('TRK-001-2024', '2024-01-06', '2024-01-09', 'Delivered' , 1),
('TRK-002-2024', '2024-01-09', '2024-01-12', 'Delivered',2),
('TRK-003-2024', '2024-01-13', NULL,          'In Transit',3),
('TRK-004-2024', '2024-01-16', '2024-01-18', 'In Transit',4),
('TRK-005-2024', NULL,         NULL,          'Cancelled',5),
('TRK-006-2024', '2024-01-21', '2024-01-23', 'Delivered',6);



INSERT INTO Order_Product (OrderNumber, ProductID, Quantity_each_product) VALUES
(1, 1,  1),
(1, 9,  1),
(2, 3,  2),
(2, 4,  1),
(3, 5,  1),
(3, 6,  1),
(4, 7,  2),
(5, 2,  1),
(5, 10, 2),
(6, 8,  1);

INSERT INTO Cart_Product (CartID, ProductID, NoOfProducts) VALUES
(1, 1,  1),
(1, 9,  1),
(2, 3,  2),
(2, 4,  1),
(3, 5,  1),
(3, 6,  1),
(4, 7,  2),
(5, 2,  1),
(5, 10, 2),
(6, 8,  1);

UPDATE Cart
SET totalPrice = (
    SELECT ISNULL(SUM(cp.NoOfProducts * p.Price), 0)
    FROM Cart_Product cp
    JOIN Product p ON cp.ProductID = p.ProductID
    WHERE cp.CartID = Cart.CartID
);