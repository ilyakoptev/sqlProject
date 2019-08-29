
-- alter tables and inserting keys
use PAG_Flowers_ver03 

go

ALTER TABLE Employees 
ADD CONSTRAINT FK_Employees_to_JobPostions FOREIGN KEY (Position) REFERENCES JobPositions (JobPositionId) ON DELETE NO ACTION
    ON UPDATE NO ACTION;
go


ALTER TABLE Customers 
ADD CONSTRAINT FK_Customers_to_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
	CONSTRAINT FK_Customers_to_Categories FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID) ON DELETE NO ACTION
    ON UPDATE NO ACTION;


go


ALTER TABLE CustomerOrders WITH NOCHECK
ADD CONSTRAINT FK_CustomerOrder_to_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustID) ON DELETE NO ACTION  ON UPDATE NO ACTION;
go
 

 ALTER TABLE Products
 ADD  CONSTRAINT FK_Products_to_Category FOREIGN KEY (CategoryID) REFERENCES  Categories (CategoryID) ON DELETE NO ACTION
    ON UPDATE NO ACTION;
 go

 
 ALTER TABLE CustomersOrderDetails
 ADD CONSTRAINT FK_CustomersOrderDetails_to_CustomerOrders FOREIGN KEY (OrderID) REFERENCES CustomerOrders (CustOrderID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
	 CONSTRAINT FK_CustomersOrderDetails_to_Products FOREIGN KEY (ProductID) REFERENCES Products (ProductID) ON DELETE NO ACTION
    ON UPDATE NO ACTION;
go

ALTER TABLE CustInvoices
ADD CONSTRAINT FK_CustInvoices_to_CustomerOrders FOREIGN KEY (OrderID) REFERENCES CustomerOrders (CustOrderID) ON DELETE NO ACTION
    ON UPDATE NO ACTION;
	go

ALTER TABLE Receipts 
ADD CONSTRAINT FK_Receipts_to_CustInvoices FOREIGN KEY (InvoiceNumber) REFERENCES CustInvoices (InvoiceID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT FK_Receipts_to_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
	CONSTRAINT FK_Receipts_to_PaymentTypes FOREIGN KEY (PaymentTypeID) REFERENCES PaymentTypes(TypeID) ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE PaymentsToSuppliers
ADD CONSTRAINT FK_PaymentToSupplires_to_Suppliers FOREIGN KEY (SupplierID) REFERENCES Suppliers (SuppID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT FK_PaymentToSupplires_to_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
	CONSTRAINT FK_PaymentsToSuppliers_to_PaymentTypes FOREIGN KEY (PaymentTypeID) REFERENCES PaymentTypes(TypeID) ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Suppliers
ADD CONSTRAINT FK_Suppliers_to_Categories FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID) ON DELETE NO ACTION
    ON UPDATE NO ACTION;
go

ALTER TABLE SuppPriceList
ADD CONSTRAINT FK_SuppPriceList_to_Products FOREIGN KEY (ProductID) REFERENCES Products (productID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
	CONSTRAINT FK_SuppPriceList_to_Suppliers FOREIGN KEY (SuppID) REFERENCES Suppliers (SuppID) ON DELETE NO ACTION
    ON UPDATE NO ACTION;
    
go

ALTER TABLE SuppOrders 
ADD CONSTRAINT FK_SuppOrders_to_Suppliers FOREIGN KEY (SupplierID) REFERENCES Suppliers (SuppID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT FK_SuppOrders_to_CustOrders FOREIGN KEY (CustomerOrderID) REFERENCES CustomerOrders (CustOrderID) ON DELETE NO ACTION
    ON UPDATE NO ACTION;
	go

ALTER TABLE SuppOrderDetails
ADD CONSTRAINT FK_SuppOrderDetails_to_SuppOrders FOREIGN KEY (OrderID) REFERENCES SuppOrders (SuppOrderID) ON DELETE NO ACTION
    ON UPDATE NO ACTION,
	CONSTRAINT FK_SuppOrderDetails_to_Products FOREIGN KEY (ProductID) REFERENCES Products (productID) ON DELETE NO ACTION
    ON UPDATE NO ACTION;

go
--ALTER TABLE SuppInvoices
--ADD CONSTRAINT FK_SuppInvoices_to_Suppliers FOREIGN KEY (SupplierId) REFERENCES Suppliers  (SuppID) ON DELETE NO ACTION
 --   ON UPDATE NO ACTION;

