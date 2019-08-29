
--creating data base and all tables

 CREATE database PAG_Flowers_ver03 ;

 go

use PAG_Flowers_ver03 

 CREATE TABLE Categories
 ([CategoryID] int not null unique , -- PK
  [CategoryName] varchar(20) not null
  CONSTRAINT PK_Categories PRIMARY KEY (CategoryID)
   )
go

CREATE TABLE Customers 
(
 [CustID] int IDENTITY(1000,1) , -- primary key
 [CRN] varchar (15) not null unique,
 [WorkName] char(5) not null unique,
 [Company] Nvarchar(20) not null,
 [ContactName] Nvarchar(50) not null,
 [Telephone] varchar (25) not null,
 [ContactName2] Nvarchar(50) ,
 [Telephone2] varchar (25),
 [Address] Nvarchar(50),
 [City] Nvarchar(30) not null,
 [Country] Nvarchar(20) not null,
 [Email] varchar(50) not null,
 [EmployeeID] int not null default 1, -- foreing key
 [CategoryID] int not null, -- FK 
 [PtmDelay] int not null default 30
 CONSTRAINT PK_Customers PRIMARY KEY (CustID)
 );
 go

 CREATE TABLE JobPositions
 ([JobPositionId] int unique, -- PK
  [JobName] nvarchar(20) 
  CONSTRAINT PK_Job PRIMARY KEY (JobPositionId)
  );

 CREATE TABLE Employees 
 ([EmployeeId] int unique not null, -- primary key
  [Name] varchar (50) not null,
  [Position] int not null,
  [Telephone] varchar (13) not null,
  [Email] varchar(50) default 'info@pag.co.il'
  CONSTRAINT PK_Employees PRIMARY KEY (EmployeeID)
 )
 go


CREATE TABLE PaymentTypes 
([TypeID] int not null,
[TypeName] nvarchar(15) not null, 
CONSTRAINT PK_PaymentTypes  PRIMARY KEY (TypeID)
)

go

CREATE TABLE CustomerOrders
([CustOrderID] int identity(20000,1) , -- primary key
 [CustomerID] int not null , -- foreign key
 [OrderIncomeDate] date not null, 
 [OrderShippingDate] date not null,
 CONSTRAINT PK_CustomerOrders PRIMARY KEY (CustOrderID)
 -- ShiperID int 
  
)

go


CREATE TABLE Products
       ([ProductID] int identity (3000,1) not null, --primary key
	    [ProductName] nvarchar(20) not null,
		[Description] nvarchar (20) ,
		[MinOrder] int not null,
		[Unit] varchar(3) not null,
		[ListPrice] money  not null,
		[CategoryID] int, -- foreign key
		CONSTRAINT PK_Products PRIMARY KEY (ProductID) 
)


go


CREATE TABLE CustomersOrderDetails
  ([ID] int identity (1,1), -- PK 
   [OrderId] int not null, --  FK
   [ProductId] int not null, --  FOREIGN KEY
   [UnitPrice] money , -- if null take price from products 
   [Qty] int not null,
   [Discount] decimal (2,2) default 0 ,
   CONSTRAINT PK_CustomersOrderDetails PRIMARY KEY (ID)
  )

  go


  CREATE TABLE CustInvoices
  ([InvoiceID] int identity (10000,1) not null, -- primary key
   [OrderId] int not null, --  foreign key
   [InvoiceDate] date not null,
   [PaymentDelay] int default 30 , -- shoef +
   [ExpPaymentDate] date,
   [Taxes %] decimal(4,2) default 17, 
   [ShipCost] decimal(10,2), -- sum(Qty)/10.0*1.3
   [TotalSum] decimal(15,2) -- qty*unitprice+taxes+shipcost
   CONSTRAINT PK_CustInvoices PRIMARY KEY (InvoiceID)
)
go

CREATE TABLE Suppliers
     ([SuppId] int identity (10,1), -- primary key 
	  [SuppName] nvarchar(20) not null,
	  [ContactName] nvarchar(10) not null,
	  [Telephone] varchar(13) not null,
	  [ContactName1] nvarchar(10) ,
	  [Telephone1] varchar(13) ,
	  [Address] nvarchar(30),
	  [Email] varchar(30) ,
	  [CategoryID] int ,-- foreign key 
	  [Payment Delay] int default 60,
	  CONSTRAINT PK_Suppliers PRIMARY KEY (SuppID)
	  )
go

CREATE TABLE SuppPricelist
       (
	    [ProductId] int not null, -- primary key/ foreign key
	    [SuppId] int not null, -- primary key/foreign key
	    [SuppPrice] money not null 
		CONSTRAINT PK_SuppPricelist PRIMARY KEY (ProductID, SuppID)
		 )
go

CREATE TABLE SuppOrders
([SuppOrderID] int identity(5000,1) , -- primary key
 [SupplierID] int not null , -- foreign key
 [OrderDate] date not null, 
 [ShippingDate] date not null,
 [CustomerOrderID] int, -- FK foreign key
 [PaymentDelay] int  default 60, -- shoef +
 [ExpPaymentDate] date, -- InvoiceDate + PaymentDelay
 [VAT %] decimal(4,2) default 17, 
 [DriverID] int default 10, 
 [Summ] decimal(15,2),
 [TotalSumm] decimal(15,2), -- qty*unitprice+taxes+shipcost
 [PmtID] varchar(5) default 'None' -- insert number if has payment for this order 
 CONSTRAINT PK_SuppOrders PRIMARY KEY(SuppOrderID)
)
go
CREATE TABLE SuppOrderDetails
  (
   [ID] int identity (1,1), -- PK 
   [OrderId] int not null, -- foreign key
   [ProductId] int not null, -- primary key/ foreign key
   [Qty] int not null,
   [Discount] decimal (2,2) default 0 
   CONSTRAINT PK_SuppOrderDetails PRIMARY KEY (OrderID,ProductID)
  )
go
  


CREATE TABLE Receipts 
([ReceiptID] int identity (1,1),
[InvoiceNumber] int not null, -- FK CustInvoices
[Payment Date] date default getdate(),
[Summ] decimal(15,2) not null ,
[PaymentTypeID] int, -- FK PaymentTypes 
[EmployeeID] int default 20 , -- FK Employees
CONSTRAINT PK_Receipts PRIMARY KEY (ReceiptID)
)

go

CREATE TABLE PaymentsToSuppliers
([PaymentID] int identity (1,1),
[SupplierId] int not null , --  foreign key
[Payment Date] date default getdate(),
[Summ] decimal(15,2) not null ,
[PaymentTypeID] int, -- FK PaymentTypes  
[EmployeeID] int default 20 , -- FK Employees
CONSTRAINT PK_PaymentsToSuppliers PRIMARY KEY (PaymentID)
)

go
