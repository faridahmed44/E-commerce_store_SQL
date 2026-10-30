SELECT customerID, Username 
FROM Customer 
WHERE Email = @Email AND [Password] = @Password;