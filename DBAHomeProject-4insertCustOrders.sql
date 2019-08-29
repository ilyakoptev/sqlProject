
--********prodecure to insert initial customers orders to the data base (random ) ***************
use PAG_Flowers_ver03
go
create procedure InsertCustOrders
@amountorders int
as
begin
declare @count int 
declare @count_in int 
declare @custid int 
declare @incomedate date
declare @shipdate date
declare @checkdate date
declare @custamount int
declare @random int
declare @tabletemp table (id int, date1 date , date2 date)
declare @aaa table (id int, date1 date , date2 date, row_num int )
SET NOCOUNT ON; 
set @count = 0
set @count_in = 1 
set @random = RAND()*365 -- range 0-365 
select @custid = min(CustID) from Customers -- first customer number in the table 
select @custamount = count(CustID) from Customers -- amount of customers in the table 

 while (@count < @custamount) -- custnumber begin from 1000 - for one customer insert "few" custOrders
   begin -- custid while --- 
        
		 while (@count_in<=@amountorders) -- number of  orders for each customer in first insert - get as parameter in procedure 
		      begin 
			    set @incomedate = DATEADD(day,-(RAND()*365) ,getdate()) -- get random order date  (-365 days from now )
	            set @shipdate = DATEADD(day,10,@incomedate) -- set shipdate 10 days from order date 
				Insert into @tabletemp values (@custid+@count, @incomedate,@shipdate) -- insert to the temp table 
				set @count_in = @count_in+1 
              end -- order insert loop
	 set @count=@count+1 
	 set @count_in = 1
		
   end ------ custid while ************
  
	insert into @aaa (id,date1,date2,row_num) 
	    select id, date1, date2, ROW_NUMBER() over (order by date1) as row_num 
		from @tabletemp -- help table to order custOrders by income date 
  
set @count = 1
select @count_in = count(date1) from @tabletemp -- use for count rows 
while (@count <= @count_in)
      begin
	    INSERT INTO CustomerOrders -- insert to CustomerOrders table in hronologic order by income date 
                    ([CustomerID],[OrderIncomeDate],[OrderShippingDate])
					select id , date1  , date2 from @aaa
					where @count_in = @count;
		set @count = @count + 1 
	  end 
SET NOCOUNT off; 
--select * from test_CustomerOrders
end --- end proc ---- 
go
--********************************************************************
go
exec InsertCustOrders 5 ; -- initial insert of numder @amountorders customers orders to the table CustOrders 
go
drop proc InsertCustOrders -- need execute just for one time to initial random orders 

select * from Customers 
select * from CustomerOrders

--**********************   insert order details ****************** 

use PAG_Flowers_ver03
go
create procedure InsertCustOrderDetails
 @amountProducts int 
as
begin -- begin proc 
declare @categoryID int
declare @amountOrders int -- total orders from orders table
declare @count int
declare @count_in int 
declare @random int
declare @minOrder int -- first CustOrderID - minimum 
declare @custID int
declare @qty int
declare @price money
declare @prodname varchar(25)
declare @minProdFL int -- first product ID category Flowers - minimum
declare @minProdHB int -- first product ID category Herbs - minimum
declare @amountProductsFL int -- total amount of products flowers
declare @amountProductsHB int -- total amount of products herbs
SET NOCOUNT ON; 
select @amountOrders = count(CustOrderID) from CustomerOrders -- amount of customer orders
select @minOrder = min(CustOrderID) from CustomerOrders -- number of first custOrdersID

select @amountProductsFL = count(ProductID) from Products where categoryID =1  -- in flowers
select @amountProductsHB = count(ProductID) from Products where categoryID =2  -- in herbs 
select @minProdFL = min(ProductID) from Products where categoryID =1 
select @minProdHB = min(ProductID) from Products where categoryID =2 


set @count = 0 -- 0 - starts from first order CustOrderId + @count 
while( @count < @amountOrders) begin --  numeber of loops = orders 
    select @custID=CustomerID from CustomerOrders where custOrderID=@minOrder + @count
	select @categoryID=categoryID from Customers where custID = @custID -- select category ID 
	set @count_in=1 -- inner counter for 5 times - 5 rows in each order
    if (@categoryID = 1) 
       while (@count_in <= @amountProducts) 
        begin 
            with random as  -- random select product from the table category flowers
                   (   select top (1)   cast((rand(checksum(newid())) * @amountProductsFL) as int) as rd
                       from  master.dbo.spt_values a cross join  master.dbo.spt_values b
                   )
                    select @random = rd from random
			-- get product details from products 
			select @price = listprice, @qty = Minorder*3,  @prodname = ProductName 
			       from Products where productId = @random+@minProdFL
			-- insert to orderDetails table 
			insert into CustomersOrderDetails ([Orderid], [productID],[UnitPrice],[Qty])
			       values (@minorder+@count,@random+@minProdFL,@price,@qty);

			set @count_in = @count_in + 1
		end
	 else  -- categoryID = 2  same action like category 1 
	     while (@count_in <= @amountProducts)
	        begin 
            with random as  -- random select product from the table category herbs
                   (   select top (1)   cast((rand(checksum(newid())) * @amountProductsHB) as int) as rd --product numbers 3016-3019
                       from master.dbo.spt_values a cross join  master.dbo.spt_values b
                   )
                    select @random = rd from random

			select @price = listprice, @qty = Minorder*10+@random*100, @prodname = ProductName 
			       from Products where productId = @random+ @minProdHB
			
			insert into CustomersOrderDetails ([Orderid], [productID],[UnitPrice],[Qty])
			       values (@minorder+@count,@random+@minProdHB,@price,@qty);
			set @count_in = @count_in + 1
		  end
      
	set @count=@count+1 -- outer counter for orders 
	end --end main while
SET NOCOUNT off; 
 end -- procedure end --*************************


--****************************************************************
go
exec InsertCustOrderDetails 5; -- insert 5 products for each customer order
go
drop procedure InsertCustOrderDetails -- execute juct ones to inital random order details 

select * from CustomersOrderDetails order by id 
--*************************************************************************


-- ************ insert customer invoices ************ 

use PAG_Flowers_ver03
go

create procedure InsertCustInvoices -- insert initial invoices for customers orders 
@delay int , --  amount of delay in month - shotef 
@taxes decimal (4,2) 
as
begin
declare @amountOrders int -- total orders from orders table
declare @minOrder int -- first CustOrderID - minimum 
declare @invoiceDate date -- same date = shipping date 
declare @paymentDate date -- same date = shipping date 
declare @count int
declare @shipCost decimal (10,2)
declare @totalSum decimal (15,2) 
SET NOCOUNT ON; 
select @amountOrders = count(CustOrderID) from CustomerOrders
select @minOrder = min(CustOrderID) from CustomerOrders

set @count = 0 -- 0 - starts from first order CustOrderId + @count 
while( @count < @amountOrders) begin --  number of loops  = orders 
    
   select @invoiceDate = OrderShippingDate from CustomerOrders where CustOrderID = @minOrder + @count
   set @paymentDate = dateadd(day,@delay%30,EOMONTH(@invoiceDate,@delay/30)) -- delay for initial inserts to the table 
   -- ship cost is invented formula 
   select @shipCost=sum(Qty)/10.0*1.3 from CustomersOrderDetails where OrderID = @minOrder + @count
   -- calculate the total summ include taxes
   select @totalsum = sum((qty*unitprice)*(@taxes/100+1))
     from CustomersOrderDetails as od join CustomerOrders as co on od.orderid=co.custorderid
	        where od.OrderID = @minOrder + @count
   
   set @totalsum = round((@totalsum + @shipcost*(@taxes/100+1)),0) -- total summ with taxes and shipping fee
      
    insert into CustInvoices ([OrderID],[InvoiceDate],[PaymentDelay], [ExpPaymentDate],[Taxes %],[shipcost],[TotalSum])
          values(@minOrder + @count,@invoiceDate,@delay, @paymentDate, @taxes,@shipcost,@totalsum);
    
   set @count= @count +1 
 end -- main while end 
 SET NOCOUNT off; 
end -- end of procedure -- ***************************************
go
exec InsertCustInvoices 30,17; -- insert initial invoices for customers with payment delay and taxes as variables
go
drop procedure  InsertCustInvoices -- execute just one time 

 select * from CustInvoices
  -- *********************************************************************************************



-- ***********insert receips from customers *****************************************
use PAG_Flowers_ver03
go
 
  
  ---************ insert receipts -----
  create procedure InsertReceipts  -- insert receipts for customers invoices (not for all) 
  as
  begin
  declare @minInvoiceNum int
  declare @amountInvoices int 
  declare @paymentDate date
  declare @summ int 
  declare @paymentTypeID int
  declare @random int
  declare @count int 
  declare @index int 
  SET NOCOUNT ON; 
  select @minInvoiceNum=min(InvoiceID) from CustInvoices 
  select @amountInvoices=count(InvoiceID) from CustInvoices
 --print @minInvoiceNum
 --print @amountInvoices
 set @count = 0 
 
 while ( @count  < @amountInvoices)   -- loop for amount of invoices - in this case 50 times 
       begin --******* begin main while *******
         
               with random as --*** add random amount dates to paymentdate
                  (   select top (1)   cast((rand(checksum(newid())) * 10) as int) as rd --product numbers 3016-3019
                       from master.dbo.spt_values a cross join  master.dbo.spt_values b
                   )
                   select @random = rd from random;

              with paymentType as -- *** random payment type 
                  (   select top (1)   cast((rand(checksum(newid())) * 4) as int) as rd -- 4 - payment types 
                       from master.dbo.spt_values a cross join  master.dbo.spt_values b
                   )
                   select @paymentTypeID = rd+1 from paymentType;

            if (@count%5 = 0) begin  -- make every 5th invoice unpaid and next reciept with random date - for future play with a data base
			    set @count = @count+1   
				set @index = 1 
				end
            --select * from test_CustInvoices
		    select @paymentDate =  ExpPaymentDate from CustInvoices where InvoiceID = (@minInvoicenum + @count )
            select @summ = Totalsum from CustInvoices where InvoiceID = (@minInvoicenum + @count )
			
			if (@index =1 ) set @paymentDate =  DATEADD(day,@random ,@paymentDate) 
			
			if (@count%8 = 0)  -- make every 8th invoice not fully paid 
			   set @summ = abs(@summ - @random*1000) -- random summ for few receipts to make part paid invoices 
			
			insert into Receipts ([Invoicenumber], [Payment Date],[Summ],[PaymentTypeId])
			       values ( @minInvoiceNum + @count,@paymentDate,@summ ,@paymentTypeID );

	  set @count = @count + 1 
	  set @index = 0 
	  
end -- ****** end main while ******
 SET NOCOUNT off; 
end -- end of procedure --***********************************
go
exec InsertReceipts;
go
drop procedure InsertReceipts

select * -- invoiceID, totalsum, summ 
   from Receipts as r right join custinvoices  as c on r.invoicenumber = c.invoiceID 
