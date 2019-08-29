


use PAG_Flowers_ver03
go

--**************************************************************

--- *********** insert supplier orders ******************

--*****************************************************************


create procedure InsertSupplierOrders -- insert order tp  supplier with order details to 2 tables (SuppOrders and SuppOrderDetails)
as
begin 

  declare @minOrderId int 
  declare @amountOrders int 
  declare @categoryID int
  declare @prodID int 
  declare @count int 
  declare @amountProd int -- amount rows in orderdetails table 
  declare @count_in int -- inner counter 
  declare @countSupp int 
  declare @random int 
  declare @suppID int 
  declare @qty int
  declare @suppOrderdate date 
  declare @suppOrderId int
  declare @delay int
  declare @expPaymentDate date
  declare @totalsumm decimal(10,2)
  declare @tabletemp table (rowNum int, prodID int ,OrderID int, qty int, suppId int, rankSupp int )
  SET NOCOUNT ON; 
  
  select @amountOrders = count(CustOrderID) from  CustomerOrders  -- total amount of customers orders
  select @minOrderID = min(CustOrderID) from  CustomerOrders -- first number of customer orders 
  
  set @count = 0 
 
  while (@count < @amountOrders) 
     begin -- main while begin ********************************
		
		 select @suppOrderdate = OrderIncomeDate from  CustomerOrders where custOrderID =  @minOrderID + @count -- same date from customer order 
		-- @minOrderID + @count - current CustOrderID 
		 -- print @count 
		 insert into @tabletemp(rowNum , prodID  ,OrderId , qty  )	-- insert ordered products to temp table 
		 	    select ROW_NUMBER() over (order by productID) as rowNum, productID as prodId ,orderid as orderID, sum(qty) as qty
				from Pag_Flowers_ver03.dbo.CustomersOrderDetails 
				group by  ProductId, orderid  
				having orderid = @minOrderID + @count
			
		 select @amountProd = count(prodID) from @tabletemp -- amount type of products in current order , because we can have same product in one order 
	                               -- suppId still NULL
		-- select * from @tabletemp 

		 set @count_in = 1 
		 while (@count_in <= @amountProd) begin
		       select @prodID = prodID , @qty = qty from @tabletemp where rowNum = @count_in -- product and qty 
			 
			   -- amount of suppliers that have this product in current row
			    select @countSupp = count(SuppID) from SuppPriceList where productID = @ProdId; 
             
			     with random as  -- select random number from count of supplier with current product 
                   (   select top (1)   cast((rand(checksum(newid())) * @countSupp) as int) as rd
                       from  master.dbo.spt_values a cross join  master.dbo.spt_values b
                   )
                 select @random = rd +1 from random; -- values from 0 then add 1 to find row number (row number begin from 1)
			
		 			with tempSupp as 
			                  ( 
							   select ROW_NUMBER() over (order by productID) as rowNum, productId as prodId, SuppId as SuppId
							   from SuppPriceList 
							   where productId = @prodID
							  )
			        select @suppID = SuppID from tempSupp where rowNum = @random ; -- select random suppID that have currect product 
			  -- @suppID - find suppID for current product 
			  -- filling @tabletemp with suppID numbers 
		      update @tabletemp set suppID = @suppID where rowNum = @count_in ;
		      set @count_in = @count_in + 1
			 end 
		--select * from @tabletemp 	
			set @count_in =1
			while (@count_in <= @amountProd) 	begin -- set rank for suppliers to find same suppliers in the table to make one order per supplier 
				update @tabletemp set rankSupp = ( select rankID from    
				 (select rowNum, ProdID, OrderID,qty, SuppID, DENSE_RANK() OVER( order by SuppID ) as rankID
			                  from @tabletemp ) as aa 
						where rowNum = @count_in ) where rowNum = @count_in
			    set @count_in = @count_in + 1
			    end  
		 
			 set @count_in = 1  
		--select * from @tabletemp 	              
			 while (@count_in<=(select max(rankSupp) from @tabletemp) ) -- new custOrderId started to order from Suppliers - new order from supplier 
			     begin
				    --print @count_in 
					select @suppID = SuppID from @tabletemp where rankSupp = @count_in -- pick first supplier from temp table 
					-- create order from suppler
					insert into SuppOrders ([SupplierId],[OrderDate],[ShippingDate],[CustomerOrderID]) -- add new supplier order 
					values(@suppID,@suppOrderdate,DATEADD(day,3,@supporderdate),@minOrderID + @count)
				    select @suppOrderID = max (suppOrderId) from SuppOrders -- new orderID number 
					-- create order details for current supplier order 
					insert into SuppOrderDetails ([OrderId],[ProductID],[Qty]) -- add suppOrder details - all rows with same supplier
					       select @suppOrderID, prodid, qty from @tabletemp where rankSupp = @count_in
				    select @delay = PaymentDelay from SuppOrders where supplierID =  @suppId
					-- calculate Estimated date of payment.
					set @expPaymentDate = 	dateadd(day,@delay%30,EOMONTH(@suppOrderdate,@delay/30))
					-- calculate total summ of supplier order 
					select @totalSumm = sum(qty*SuppPrice)
					       from SuppOrderDetails as od join SuppOrders as so on od.orderid=so.suppOrderid
                           join SuppPriceList as pl on pl.productid=od.productid and so.SupplierID=pl.SuppId
                           where suppId = @suppID and CustomerOrderID = @minOrderID + @count

                     -- insert calculated vaariables to SuppOrders table 
					 update SuppOrders set ExpPaymentDate = @expPaymentDate, Summ = @totalSumm, TotalSumm = @totalSumm*((select [Vat %] from suppOrders where suppOrderID=@suppOrderID)/100+1) where suppOrderID = @suppOrderID ;
				
				set @count_in = @count_in + 1
				end 
			
		 set @count=@count+1 -- next CustOrderID 
		 delete @tabletemp -- clear temp table for next loop 
    end -- main while end -- go to next orderID **********
  SET NOCOUNT off; 
 end -- end of procedure -- *************************************************
 go
 exec InsertSupplierOrders
 go
 drop procedure InsertSupplierOrders
 go
 select * 
	from SuppOrderDetails as od join SuppOrders as so on od.orderId = so.SupporderID 

--*****************************************************
 --********** Payment to Suppliers ***************

use PAG_Flowers_ver03
go

create procedure InsertPayments  -- insert payments to suppliers 
as 
begin
declare @amountSuppOrders int 
declare @SuppID int 
declare @amountSupp int
declare @minSupp int 
--declare @firstnum int
declare @firstdate date -- date of first order for customer 
declare @lastdate date -- date of last order for customer 
declare @count int 
declare @countDate int 
--declare @random int 
declare @paymentTypeID int  
declare @index int 
declare @paymentDate date
declare @summ decimal (10,2)
declare @tabletemp table (        
			[RowNum] int ,
			[SupplierId] int , 
			[Payment Date] date,
			[Summ] int  ,
			[PaymentTypeID] int 

)
SET NOCOUNT on; 
set @count = 0 
 
select @amountSupp = count(SuppID) from Suppliers -- amount of suppliers in the supplier table 
select @minSupp = min(suppID) from Suppliers -- first suppID 

 while ( @count  < @amountSupp)   -- loop for all of suppliers one per loop  -
       begin --******* begin man while *******
             select @firstdate = min(OrderDate) from SuppOrders where SupplierID = @minSupp + @count -- date of first order
		     select @lastdate = max(OrderDate) from SuppOrders where SupplierID = @minSupp + @count; -- date of last order
		    -- print @firstdate
			-- print @lastdate;
		
		   --payment for each month of supplier orders history 
		   set @countDate = 0 
		set @index = DATEDIFF(month, @firstDate, @lastDate) -- count monthes between first and last orders for the loop counter
		while(@countDate <= @index and EOMONTH(@firstDate) != EOMONTH(cast(getdate()as date))) 
		    begin  
			    if (@countDate%7 = 0) begin -- each 7th not paid
			        set @countDate = @countDate+1   
				    continue
			    end;
			   with paymentType as -- *** set random payment type 
                  (   select top (1)   cast((rand(checksum(newid())) * 4) as int) as rd -- 4 - payment types 
                       from master.dbo.spt_values a cross join  master.dbo.spt_values b
                   )
                   select @paymentTypeID = rd+1 from paymentType;
         
			   select @Summ = sum(TotalSumm)
                  from  SuppOrders  
	                  where supplierId = @minSupp + @count  and (Orderdate between @firstDate and EOMONTH(@firstDate) ) -- current supplier and dates in same month
               if (@summ is null) 
			       begin set @countDate = @countDate+1   continue end  -- if in this month no orders from current supplier movet to next month
		    
			set @suppId = @minSupp + @count -- set current supplier number
		    select @paymentDate = [expPaymentDate] from SuppOrders 
			insert into @tabletemp (SupplierID,[Payment Date],Summ,PaymentTypeID)
			       values (@suppID,EOMONTH(@firstDate,2), @Summ, @paymentTypeID)
			set @countDate  = @countDate  + 1 
			set @firstDate = DATEADD(day, 1, EOMONTH(@firstDate)) -- moving to next month 
		 
		 end; -- end of loop monthly payments to suppliers
	     --select * from @tabletemp	;
	  set @count = @count + 1 
	  set @index = 0 
	  
 end; -- ****** end main while ******
 with OrderDates as -- sort payments by payment day 
                  (    select ROW_NUMBER() over (order by [Payment Date]) as rowNum, 
		                 SupplierID,[Payment Date],Summ,PaymentTypeID  from @tabletemp
                   )
        ---  select * from OrderDates
		  insert into @tabletemp (RowNum,SupplierID,[Payment Date],Summ,PaymentTypeID )
		           select RowNum,SupplierID,[Payment Date],Summ,PaymentTypeID from OrderDates
		--select * from @tabletemp	;
		set @count = 1
		while (@count < (select max(rowNum) from @tabletemp))
		 begin  
		    insert into PaymentsToSuppliers ([Payment Date],SupplierID,Summ,PaymentTypeID)
		        select [Payment Date],SupplierID,Summ,PaymentTypeID from @tabletemp
				   where rowNum = @count
            -- use @index as help variable for insert paymentID 
		    select @index = PaymentID , @SuppID =  SupplierID, @lastdate = [Payment Date] 
			from PaymentsToSuppliers where paymentID = 
			                                 ( select max(PaymentID) from PaymentsToSuppliers) -- last payment
		    
			update SuppOrders set  [PmtID]  = @index   -- insert paymentId to SuppOrderID instead "none" as default
			       where   supplierId = @SuppID  
				           and  month(dateadd(month,-2,@lastdate)) = month(Orderdate)  
						   and  year(dateadd(month,-2,@lastdate)) = year(Orderdate)   -- 
			 set @count = @count + 1 
			 end 
       -- select * from PaymentsToSuppliers

SET NOCOUNT off; 
 end -- ******* end of procedure 
 go

 exec InsertPayments
 go
 drop procedure InsertPayments
 go

select * from PaymentsToSuppliers
go 
