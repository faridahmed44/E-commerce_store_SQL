UPDATE Shipment
SET ShippingStatus = @NewStatus, 
    PickupDate = CASE WHEN @NewStatus = 'Shipped' THEN GETDATE() ELSE PickupDate END,
    DeliveryDate = CASE WHEN @NewStatus = 'Delivered' THEN GETDATE() ELSE DeliveryDate END
WHERE TrackingID = @TrackingID;