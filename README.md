# sqlProject

Project PAG Flowers – sample database for export flowers.

1.	ER Diagram
2.	Build the data base 
3.	Random entering initial data to data base
4.	Procedures to make sample functions (add/edit/remove customer, add customer order, add supplier order)
 


Tables:
1. Categories (1,2 – Flowers or Herbs) – categories of Products
2. Customers
3. JobPositions
4. Employees
5. PaymentTypes (for Receipts and payments)
6. Customer Orders
7. Customers Order Details
8. Products ( 2 – categories)
9. Customer Invoices 
10. Suppliers
11. Suppliers price list (same products for several suppliers)
12. Suppliers Orders (order from supplies on basis customer orders)
13. Supplier order details
14. Receipts – payment from Customers 
15. Payments – payments to Suppliers 


Instructions:
10 files with names started 1-10. (just execute by number order) 
1. Create database and tables
2. Alter tables and add contractions 
3. Insert data to data base (Static data)
4. Insert random data to Customers order, Customer order details, Customer Invoices and receipts tables  based on inserted static data (Customers,Suppliers,Products and date range – 365 days.  
(Run procedures in this file as is)
5. Insert data to Supplies tables (using data from Customer orders tables) (Run procedures in this file as is.)
6. File with stored procedures: Add/Edit/Delete Customers with all possibility checks. (Run procedures as is – execute file be later)
7. Stored procedures to add order from Customer, create invoice for Customer and Receipt. (Run file as is – execute file be later)
8. Create store procedures for Supplier – add Supplier order (by customer order) and payment to Supplier (Run file as is)
9. Some “select” procedures like Customer Balance, Final Balance, Sales statistic. 
10. File with execute all procedures with name and instruction about variables. 



File number 10 with instruction:

use PAG_Flowers_ver03
go

--**** exec procedures by name 
--  create new customer  with check all field (Numbers, Telephone, E-mail, if exists… )

EXEC AddNewCustomer  '323678845','OLG','Olga LTD ','Olga','7 ( 952)674- 33-98','Sergey','7 ( 952)674- 98-98','5 ','Moscow','russia','olgadavid@gmail.com',1;
Go

--  delete customer  only if he has not any orders ( insert or custID, Or CRN, or WorkName)
exec DeleteCustomer OLg; -- custID/CRN/WorkName
go

--  edit customer  - insert or custID, Or CRN, or WorkName, column to change and value ( all checks include)
exec EditCustomer del, city, kolomna; -- custID/CRN/WorkName, Column , Value
go

-- add one product in time, but if all inserts in same date add to the exists order with same date (custID or CRN or WorkName,  ProductID,  Amount)
exec  AddNewCustomerOrder  1001,3012,200; -- custID/CRN/WorkName,  ProductID,  Amount
go 

-- create invoice for customer .if entered custID or  WorkName will create invoice for all last orders without invoices. if entered OrderId – make invoice just for this order
exec CreateCustomerInvoice 21090 ; -- custID /  WorkName / OrderId
go

-- create receipt from customer by invoiceID, @summ, @paymenttype
exec InsertReceipt 10090, 2000, 4; -- invoiceID, @summ, @paymenttype
go

 -- then we want order products from supplier, so we enter @custOrderID and create orders from suppliers (randomly with same products)
exec CreateSuppOrder 20090;  -- @custOrderID 
go


-- if entered suppOrderID then can make payment only for this order with exact sum. If entered SuppID  will close older unpaid suppliers orders. 
exec CreateSuppPayment 5049, 702, 2 -- suppOrderID/SuppID , summ, paymentTypeID 
go

-- Customer Balance for entered month .enter CustID or WorkName or CRN , month (in number, 0 - for all months), year (XXXX)
exec CustomerBalance ama, 9, 2018 --  -- CustID/WorkName/CRN , month (in number, 0 - for all months), year (XXXX or 0 for all exists years)
go

--  Customer Final sum of balance – enter CustID or WorkName or CRN (equal to last field in CustomerBalance @custID,0,0) 
exec CustomerFinalBalance 1012 --  -- CustID/WorkName/CRN 
go

-- some statistic about sales per entered values (if value ‘0’ = all values)
exec ProductSales 'eus', '2018-10-12', '2019-05-23', 1000  -- productID/product name/ part of product name, 
go                                                           -- startDate, endDate, CustID/WorkName/CRN (if one of values is 0 - get all)



Still in process, add additional procedures to this project like Add/Edit Supplier, Add/Edit Products and BI/Statistics queries. 

And organize all check fields function to separate file because most checks are the same. 


Last updates: 
1.	File #7. Bug in CreateCustomerInvoice procedure – line 142 (select count(UnpaidOrders) from @unpaidOrders) – done
2.	File #10. Add total balance field and change fields with NULLs in CustomerBalance procedure 
