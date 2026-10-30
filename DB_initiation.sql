
--Orders instead of Order
--Order_Product instead of Include
--Cart_Product instead of AddedTo


-- Create Database
--CREATE DATABASE ECommerceStore;
--GO

USE EcommerceDB;
GO

-- =========================
-- 1) Customer
-- =========================
CREATE TABLE Customer (
    customerID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    [Password] VARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(11) NOT NULL
);


-- =========================
-- 2) Customer_Address
-- =========================
CREATE TABLE Customer_Address (
    --addressID INT IDENTITY(1,1) PRIMARY KEY,
    customerID INT NOT NULL PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(150) NOT NULL,
    buildingNo INT NOT NULL,
    apartmentNo INT NULL,
    CONSTRAINT FK_CustomerAddress_Customer
    FOREIGN KEY (customerID) REFERENCES Customer(customerID)
);


-- =========================
-- 3) ProductCategory
-- =========================
CREATE TABLE ProductCategory (
    categoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description_C TEXT NULL
);


-- =========================
-- 4) Product
-- =========================
CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    stockQuantity INT NOT NULL,
    Description_P TEXT NULL,
    categoryID INT NOT NULL,
    CONSTRAINT FK_Product_Category
        FOREIGN KEY (categoryID) REFERENCES ProductCategory(categoryID)
);


-- =========================
-- 5) Review
-- =========================
CREATE TABLE Review (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    Comment TEXT NULL,
    Rate INT NOT NULL CHECK (Rate BETWEEN 1 AND 5),
    customerID INT NOT NULL,
    ProductID INT NOT NULL,
    CONSTRAINT FK_Review_Customer
        FOREIGN KEY (customerID) REFERENCES Customer(customerID),
    CONSTRAINT FK_Product_ID
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);


-- =========================
-- 6) Cart
-- =========================
CREATE TABLE Cart (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    totalPrice DECIMAL(10,2) NOT NULL DEFAULT 0,
    customerID INT NOT NULL,
    CONSTRAINT FK_Cart_Customer
        FOREIGN KEY (customerID) REFERENCES Customer(customerID)
);
-- =========================
-- 7) Orders  
-- =========================
CREATE TABLE Orders (
    OrderNumber INT IDENTITY(1,1) PRIMARY KEY,
    orderDate DATE NOT NULL,
    [status] VARCHAR(50) NOT NULL,
    customerID INT NOT NULL,
    CONSTRAINT FK_Orders_Customer
      FOREIGN KEY (customerID) REFERENCES Customer(customerID)
   


);

-- =========================
-- 8) Payment
-- =========================
CREATE TABLE Payment (
    paymentID INT IDENTITY(1,1) PRIMARY KEY,
    [Date] DATE NOT NULL,
    [Status] VARCHAR(50) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Method VARCHAR(50) NOT NULL,
    OrderNumber INT not null,
     CONSTRAINT FK_Order_Number1
       FOREIGN KEY (OrderNumber) REFERENCES Orders(OrderNumber)
    
    
);

-- =========================
-- 9) Shipment
-- =========================
CREATE TABLE Shipment (
    shipmentID INT IDENTITY(1,1) PRIMARY KEY,
    TrackingID VARCHAR(100) NOT NULL UNIQUE,
    PickupDate DATE NULL,
    DeliveryDate DATE NULL,
    ShippingStatus VARCHAR(50) NOT NULL,
    OrderNumber INT not null,
    CONSTRAINT FK_Order_Number
       FOREIGN KEY (OrderNumber) REFERENCES Orders(OrderNumber)
    
);



-- =========================
-- 10) Order_Product
-- include 
-- =========================
CREATE TABLE Order_Product (
    OrderNumber INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity_each_product INT NOT NULL,
    Total_No_of_products INT NULL,
    PRIMARY KEY (OrderNumber, ProductID),
    CONSTRAINT FK_OrderProduct_Orders
        FOREIGN KEY (OrderNumber) REFERENCES Orders(OrderNumber),
    CONSTRAINT FK_OrderProduct_Product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);


-- =========================
-- 11) Cart_Product
-- added_to
-- =========================
CREATE TABLE Cart_Product (
    CartID INT NOT NULL,
    ProductID INT NOT NULL,
    NoOfProducts INT NOT NULL,
    PRIMARY KEY (CartID, ProductID),
    CONSTRAINT FK_CartProduct_Cart
        FOREIGN KEY (CartID) REFERENCES Cart(CartID),
    CONSTRAINT FK_CartProduct_Product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
