
 use PAG_Flowers_ver03
 go


 create procedure AddNewCustomerOrder 
 @Customer varchar (6),
 @productID varchar(6),
 @qty varchar(6)
 as 
 -- order has been added to last order from this customer if dateOrder today, of not - new orderID 
 begin -- start procedure 
 
 --declare @Customer varchar (6)
 --declare @productID varchar(6)
 --declare @qty varchar(6) 
 --set @Customer = '1015'
 --set @productID = '3006'
 --set @qty = '400' 
 
 declare @customers int -- customer ID for the order 
 declare @count int 
 declare @custID int -- customer ID for the order
 declare @orderID int --
 declare @orderDate date
 declare @unitprice money 
 declare @flag int -- 1 - exists, 0 - not exists 

if (@customer like cast((select custID from Customers where  custID like @Customer) as varchar(10))
               or @customer like cast((select CRN from Customers where  CRN like @Customer) as varchar(10))
			   or exists (select WorkName from Customers where  WorkName like @Customer))
   -- get custID for current customer for follow operations 
  select @CustID = CustID from Customers  where custID like @Customer or crn  like @Customer or workname like @Customer
   else set @flag = 0 

if (@flag = 0 ) begin print 'Customer not exists or you enter a wrong name or number' return end

 -- check productID 
 if (@productID not between '0' and '9' or (select ProductID from Products where ProductId = @productID) is null) begin 
      declare @a varchar(10)
	  declare @b varchar(10)
	  select @a=min(productid), @b=max(productID) from Products
	  print 'Please enter right productID between ' + @a + ' and ' + @b return end 
 
 -- check category for product 
 
 if ( (select CategoryID from Products where productID = @productID)!= (select CategoryID from Customers where CustId = @CustID))
     begin 
	   print 'Product category is unsuitable for this Customer ' return end 
 
 --check qty 
 
 if ( ISNUMERIC(@qty) = 0 ) begin print 'Please enter right Qty of products' return end 

 set @productID = cast(@productId as int)
 set @qty = cast (@qty as int) 
 
 select @orderDate = max(OrderIncomeDate) from CustomerOrders where CustomerID = @custID -- check last order income date
 
 select @orderID = max(CustOrderID) from CustomerOrders where CustomerID = @custID and OrderIncomeDate = cast(getdate() as date)
	
 if(@orderdate = (cast(getdate() as date)) and not exists (select CustomerOrderID from SuppOrders where CustomerOrderID = @orderID)) -- add to the last order 
     begin
  	   select  @unitprice = listprice from Products where ProductID = @productid
	   if(@qty < (select minOrder from Products where Productid=@productid))
	     select @qty = minOrder from Products where Productid=@productid
      
       insert into CustomersOrderDetails (OrderID,ProductID,UnitPrice,Qty)
	          values (@orderID,@productID,@unitprice,@qty)
	 end 
 else begin  -- add new orderID 
      insert into CustomerOrders(CustomerID, OrderIncomeDate , OrderShippingDate )
	         values(@custID,cast(getdate() as date),cast(dateadd(day,10,getdate()) as date))

	 select  @unitprice = listprice from Products where ProductID = @productid
	 select @orderID = max(CustOrderID) from CustomerOrders where CustomerID = @custID and OrderIncomeDate = cast(getdate() as date)
	  
      insert into CustomersOrderDetails (OrderID,ProductID,UnitPrice,Qty)
	         values (@orderID,@productID,@unitprice,@qty)

	end  

 end -- end of procedure 
 go
 --***********************************************************
 
 --select * 
 --from CustomerOrders as co left join customersOrderDetails as od on co.custOrderID=od.orderid
 
 --**************************************************************

 --*******************************************************
 use PAG_Flowers_ver03
 go
 
 ---****************************************************************************************************************
 create procedure CreateCustomerInvoice   -- create invoice -> OR for special orderID -> OR for all orders without invoices for current customer 
 @variable varchar(10) -- or name or custId or orderId
 --@orderID varchar(7)
 -- @delay varchar(3) 

 as
 begin -- start procedure 
 --declare @orderID varchar(7)
 -- declare @variable varchar(10)
 --set @orderID ='21101'
 -- set @variable = 1002
 
 declare @delay varchar(3)  
 declare @invoiceID int 
 declare @expPaymentDate as date
 declare @shipcost decimal(10,2)
 declare @totalsum decimal(15,2)
 declare @taxes decimal (4,2)
 declare @unpaidOrders table (UnpaidOrders int, rowNum int) -- table with unpaid orders
 declare @customer int
 declare @orderID varchar(7)
 declare @count int
 set @customer = 0
 set @orderID = 0
 set nocount on;
 --select * from @unpaidOrders	

 -- insert to unpaid orders to table unpaidOrders 
 if exists (select CustOrderID from CustomerOrders where CustOrderID like @variable) -- if procedure  get a orderId 
   	 if  exists (select OrderID from CustInvoices where OrderID like @variable)
	      begin print 'This order already has invoice' return end 
	 else
	  insert into @unpaidOrders (UnpaidOrders) -- insert to table with unpaid orders
		       values (cast(@variable as int))  
-- select * from @unpaidOrders	   
--check if orderId have details - of special OrderId of from unpaidorders
 else if exists (select custID from Customers where custID like @variable or WorkName like @variable) -- if procedure get a customer 
        begin   -- get custID from input 
		 select @customer = custID from Customers where custID like @variable or WorkName like @variable
		
		 insert into @unpaidOrders (UnpaidOrders) -- insert all order for current customer into unpaid orders table 
		        select CustOrderID 
				      from  CustomerOrders as co left join CustInvoices as ci on co.CustOrderID=ci.OrderId
				      where CustomerId = @customer and invoiceId is null
         
		 if ((select count(UnpaidOrders) from @unpaidOrders) = 0 ) -- check if customer have unpaid orders 
		    begin print 'There are not orders without invoices for this customer' return end

        end 
--select * from @unpaidOrders	 
else -- if input with aplready paid orderID  print list with unpaid orders for this customer
     begin 
	   if (isnumeric(@variable)=0) begin print 'Please check your enter data!' return end
	   else
	     begin
	       insert into @unpaidOrders	(UnpaidOrders,rowNum)
		      select   custOrderID , ROW_NUMBER() over (order by custOrderID) as rowNum
		      from CustInvoices as ci right join CustomerOrders as co on ci.orderID = co.CustOrderID
		      where ci.orderId is null 
	      declare @temp int 
		  set @count = 1 
	      print 'Please select OrderId without invoices from the list:'
	      while(@count <= (select count(rowNum) from @unpaidOrders)) 	begin
	            select @temp=UnpaidOrders from @unpaidOrders where rowNum = @count
		    	print @temp  
		    	set @count=@count+1  
	      return end -- exit from procedure 
	    end
     end
-- select * from @unpaidOrders	

 select @delay = PtmDelay -- get payment delay from Customers table
       from Customers as c join CustomerOrders as co on c.CustID=co.CustomerID
	   where co.CustOrderID = (select top 1 UnpaidOrders from @unpaidOrders);

	   --- insert rownumbers to unpaid table for following loop 
   with temp as   (select unpaidOrders, ROW_NUMBER() over (order by unpaidOrders) as rowNum from @unpaidOrders)
	  insert into @unpaidOrders (unpaidOrders, rowNum)
	     select unpaidOrders, rowNum from temp;
 
 -- cast variables to integer for inserting to invoices table 
 set @delay=cast(@delay as int)
 set @orderID=cast(@orderID as int)

 -- insert new custoner invoice to custInvoices table with calculate 
 begin try 
   
   set @count = 1 
   set @expPaymentDate = dateadd(day,@delay%30,EOMONTH(cast(getdate() as date),@delay/30))
   while (@count <= (select count(rowNum) from @unpaidOrders where rowNum is not null))
         begin  
             select @orderID = unpaidOrders from @unpaidOrders where rowNum = @count
			 insert into CustInvoices (OrderID,InvoiceDate,PaymentDelay,ExpPaymentDate) -- insert new entry - invoice 
                 values(@orderid,cast(getdate() as date),@delay,@expPaymentDate )
			 select @invoiceID = InvoiceID from CustInvoices where OrderID = @orderID 
             select @shipCost=sum(Qty)/10.0*1.3 from CustomersOrderDetails where OrderID = @orderID  -- can create table with ship costs and VATs
             -- IMPORTANT - change when swith data base from test_dataBase
             select @taxes = [taxes %] from CustInvoices where orderID = @OrderID -5 -- -- can create table with ship costs and VATs
             -- select @taxes = [taxes %] from test_CustInvoices where InvoiceID = @InvoiceID
             select @totalsum =  sum((qty*unitprice)*(@taxes/100+1)) 
                   from CustomersOrderDetails as od join CustomerOrders as co on od.orderid=co.custorderid
	               where od.OrderID = @orderID
             set @totalsum = round((@totalsum + @shipCost*(@taxes/100+1)),0)
        update CustInvoices  -- update new invoice entry 
               set 
			       ShipCost = @shipcost,
			       TotalSum = @TotalSum 
               where InvoiceID = @invoiceID 
        set @count = @count + 1
		end
		
 end try 
 begin catch 
     print ' Error to create invoice for this orderId '   			  
  --print @invoiceID
  --print @orderID
  --print cast(getdate() as date)
  --print @expPaymentDate
  --print @shipcost
  --print @totalsum 
 end catch 
 set nocount off;
 --select * from CustInvoices where InvoiceID = @invoiceID
  end -- end of procedure **************************************************
  go





 --********** Insert Receipt from customer *************8
 use PAG_Flowers_ver03
 go
 
 create procedure InsertReceipt
 @invoiceID varchar (7),
 @summ varchar (10), 
 @type varchar(2)
 as
 begin
 --declare @invoiceID varchar (10)
 --declare @summ varchar (10) 
 --declare @type varchar(2)
 
 set nocount on;
 
 --set @invoiceID = '10145'
 --set @summ = '16000' 
 --set @type = '4'
 

   if(@invoiceID like cast((select invoiceID from CustInvoices where  invoiceID like @invoiceID) as varchar(10)))
     set @invoiceID = cast(@invoiceID as int) -- 
  else begin print 'Please enter right and exists Invoice number' return end

  if (isnumeric(@summ) = 0 ) 
    begin print 'Please enter numeric summ' return end
	else set @summ = cast(@summ as int)

 if (@type like cast ((select typeID from PaymentTypes where typeID like @type )as int))
    set @type = cast(@type as int)
	else begin print 'Please enter right payment type number: (1-Cash),(2-Check),(3-Bank Transfer),(4-Credit Card)' return end
 
if((select sum(summ) from Receipts where invoiceNumber=@invoiceID)>=(select totalsum from CustInvoices where InvoiceID=@invoiceID ))
  begin print 'This invoice was paid in past. Please enter another invoice number' return end 

if (@summ + (select sum(summ) from Receipts where invoiceNumber=@invoiceID)> (select totalsum from CustInvoices where InvoiceID=@invoiceID ))
   print 'Warning! Summ you want to pay more than invoice total summ. You will be in credit' 
else if (@summ + (select sum(summ) from Receipts where invoiceNumber=@invoiceID) < (select totalsum from CustInvoices where InvoiceID=@invoiceID ))
   print 'Warning! Summ you want to pay less than invoice total summ. You must to pay more next time' 

insert into Receipts ([InvoiceNumber],[Payment Date],[Summ],[PaymentTypeID])
    values (@invoiceID,cast(getdate() as date),@summ,@type);

set nocount off;
 end -- end procedure *********************************8
 go
