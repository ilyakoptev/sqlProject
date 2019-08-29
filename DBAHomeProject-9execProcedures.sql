
use PAG_Flowers_ver03
go
--**** exec procedures by name 
EXEC AddNewCustomer  '323678845','OLG','Olga LTD ','Olga','7 ( 952)674- 33-98','Sergey','7 ( 952)674- 98-98','5 ','Moscow','russia','olgadavid@gmail.com',1;
go

exec DeleteCustomer OLg; -- custID,CRN,WorkName
go

exec EditCustomer del, city, kolomna; -- custID/CRN/WorkName, Column , Value
go

exec  AddNewCustomerOrder  1002,3010,200; -- custID/CRN/WorkName,ProductID,Amount
go 

exec CreateCustomerInvoice 1002 ; -- custID /  WorkName / OrderId
go

exec InsertReceipt 10090, 2000, 4; -- invoiceID, @summ, @paymenttype
go
 
exec CreateSuppOrder 20091;  -- @custOrderID 
go

exec CreateSuppPayment 11, 50000, 4 -- suppOrderID/SuppID , summ, paymentTypeID 
go

exec CustomerBalance 1001, 0, 0 --  -- CustID/WorkName/CRN , month (if number, 0 - for all monthes), year (XXXX or 0 for all years)
go

exec CustomerFinalBalance 1001 --  -- CustID/WorkName/CRN  - print final balance 
go

exec ProductSales 'ruscus', '2018-10-12', '2019-05-23', 0  -- productID/product name/ part of product name, 
go                                                           -- startDate, endDate, CustID/WorkName/CRN (if one of values is 0 - get all)


exec SupplierBalance 10, 0, 0 -- SuppID, month (if number, 0 - for all monthes), year (XXXX or 0 for all years)
go


--**********************
use PAG_Flowers_ver03
go

 drop PROCEDURE AddNewCustomer  ;
 go
 drop procedure DeleteCustomer ;
 go
 drop procedure EditCustomer;
 go
 drop procedure AddNewCustomerOrder ;
 go
 drop procedure CreateCustomerInvoice;
 go
 drop procedure InsertReceipt;
 go 
 drop procedure CreateSuppOrder;
 go
 drop procedure  CreateSuppPayment;
 go
 drop procedure CustomerBalance
 go
 drop procedure CustomerFinalBalance
 go
 drop procedure ProductSales
 go


 select * from Customers 
 select * from CustomerOrders where CustomerID=1001
 
 select * from custInvoices where orderID = 20090
 delete custInvoices where invoiceID = 10181
  
  select * from CustomerOrders as co
  left join CustInvoices as ci on co.CustOrderID=ci.OrderId
  where custorderid = 20090
 

select * from CustomersOrderDetails where OrderID = 20090


 delete CustomerOrders where CustOrderID = 21101 

 select * from CustInvoices where custorderid = 20091

 select * 
 from custInvoices as ci left join Receipts as r on ci.InvoiceID=r.InvoiceNumber

 
select *
from suppOrders as so join SuppOrderDetails as od on so.supporderid=od.orderid
where CustomerOrderID = 20091


select * from SuppOrders where PmtID like 'none'


select * from SuppOrders where SupplierID = 13
select * from PaymentsToSuppliers where SupplierID = 14
select sum(TotalSumm) from SuppOrders where SupplierID=14 
select sum(Summ) from PaymentsToSuppliers where SupplierID=14
select  min(SuppOrderID) from SuppOrders where PmtID like 'None' and SupplierID = 14
declare @summtemp decimal (10,2)
set @summtemp =  (select sum(TotalSumm) from SuppOrders where SupplierID=14 ) -- supplier balance
		           - (select sum(Summ) from PaymentsToSuppliers where SupplierID=14)  
                print 'Your payment was recieved. Current Balance with this supplier include this payment is '--  + cast(@summtemp as varchar(10)
                print @summtemp