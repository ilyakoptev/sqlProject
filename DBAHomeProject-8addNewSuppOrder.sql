use PAG_Flowers_ver03
 go


-- @custOrderid -- we have list of products in orderDetails table 
create procedure CreateSuppOrder 
@custOrderId varchar(6) 
as 
begin -- start procedure
--declare @custOrderId varchar(6)
--set @custOrderId  = '20091'

declare @amountProd int -- amount products in one customer order 
declare @count int -- count for the loop 
declare @tabletemp table (rowNum int, prodID int ,OrderID int, qty int, suppId int, rankSupp int ) -- help temporary table 
declare @prodID int 
declare @qty int 
declare @countSupp int
declare @random int 
declare @suppID int 
declare @flag int 
declare @suppOrderId int 
declare @delay int
declare @expPaymentDate date
declare @Summ decimal (10,2)
set @count =1 
set @flag = 0 
set nocount on;
if (isnumeric(@custOrderID)=0) begin print 'Please enter a rigth Customer order ID' return end
   
if (@custOrderId = (select top 1 CustomerOrderID from SuppOrders where CustomerOrderID like @custOrderId))
  begin print  'For this customer order already ordered products from suppliers. Enter another order ID.' return end


--while (@count <= @amountProd) -- loop for number of products in the customer order 
                
		       insert into @tabletemp(rowNum , prodID  ,OrderId , qty  )	
		 	   select ROW_NUMBER() over (order by productID) as rowNum, productID as prodId ,orderid as orderID, sum(qty) as qty
				    from CustomersOrderDetails 
				    group by  ProductId, orderid  -- having orderid = 20000
				    having orderid = @custOrderId
			
			--select * from 	@tabletemp
				
			  select @amountProd = count(prodID) from @tabletemp where orderID =  @custOrderId -- amount of products = rows in table 
	   	-- print @amountProd
			 
		 while (@count <= (select count(prodID) from @tabletemp where orderID =  @custOrderId )) 
		    begin -- loop for rows in temp table 
		       select @prodID = prodID , @qty = qty from @tabletemp where rowNum = @count
			   select @countSupp = count(SuppID) from SuppPricelist where productID = @ProdId;
			 		   
                with random as  -- random select supplier with the same product  
                   (   select top (1)   cast((rand(checksum(newid())) * @countSupp) as int) as rd
                       from  master.dbo.spt_values a cross join  master.dbo.spt_values b
                   )
                    select @random = rd +1 from random;
			  --select suppID from SuppPricelist where rowNum = @count_in 
			
			    with tempSupp as 
			                  ( 
							   select ROW_NUMBER() over (order by productID) as rowNum, productId as prodId, SuppId as SuppId
							   from SuppPricelist 
							   where productId = @prodID
							  )
			    select @suppID = SuppID from tempSupp where rowNum = @random ;
			 
			    update @tabletemp set suppID = @suppID where rowNum = @count ; -- insert supplier for product in from random search
		      set @count = @count + 1
			end 
			-- select * from 	@tabletemp
            --  select rowNum, ProdID, OrderID,qty, SuppID, DENSE_RANK() OVER( order by SuppID ) as rankID
			--                  from @tabletemp 
			set @count =1
			while (@count <= @amountProd) 	begin -- set rank for suppliers for create one order for same supplier
				update @tabletemp set rankSupp = ( select rankID from    
				 (select rowNum, ProdID, OrderID,qty, SuppID, DENSE_RANK() OVER( order by SuppID ) as rankID
			                  from @tabletemp ) as aa 
						where rowNum = @count ) where rowNum = @count
			    set @count = @count + 1
			end  
		 --select * from 	@tabletemp   
		  set @count = 1
			  while (@count<=(select max(rankSupp) from @tabletemp) ) -- new custOrderId started to order from Suppliers - new order from supplier 
			     begin
				    select @suppID = SuppID from @tabletemp where rankSupp = @count -- pick first supplier from temp table 
					insert into SuppOrders ([SupplierId],[OrderDate],[ShippingDate],[CustomerOrderID]) -- add new supplier order 
					values(@suppID,cast(getdate() as date),DATEADD(day,3,cast(getdate() as date)), @custOrderId)
				    select @suppOrderID = max (suppOrderId) from SuppOrders -- new orderID number 

					insert into SuppOrderDetails ([OrderId],[ProductID],[Qty]) -- add suppOrder details - all rows with same supplier
					       select @suppOrderID, prodid, qty from @tabletemp where rankSupp = @count
				    select @delay = PaymentDelay from SuppOrders where supplierID =  @suppId
					
					set @expPaymentDate = 	dateadd(day,@delay%30,EOMONTH(cast(getdate() as date),@delay/30))
										
                    select @Summ = sum(suppPrice*Qty) -- SuppOrderId, SupplierID, OrderDate, od.ProductID, SuppPrice 
                           from SuppOrders as so join SuppOrderDetails as od on so.SuppOrderID=od.OrderId
                           join SuppPricelist as pr on so.SupplierID=pr.SuppId and od.ProductId=pr.ProductId -- (suppID and ProdID) 
                           where SupplierID = @suppID and CustomerOrderID = @custOrderId
   
   					update SuppOrders 
					       set ExpPaymentDate = @expPaymentDate, 
						       Summ = @Summ, 
							   TotalSumm = @Summ*( (select [Vat %] from suppOrders where suppOrderID=@suppOrderID)/100+1)
						   where suppOrderID = @suppOrderID ;	    
				set @count = @count + 1
			end 
		
		 delete @tabletemp -- clear temp table for next loop 
     
set nocount off;		 
end -- end procedure 
go

---****************************************************************************
--- *** payment to Supllier *** -----

create procedure CreateSuppPayment  -- get or suppID or suppOrderID (if suppId -> older unpaid order else -> this order)
@variable int , -- suppID or suppOrderID ( if entering suppOrderID then can pay just till total sum of this orderID )
@summ decimal (10,2), -- suum of payment
@paymentType int -- type of payment 
as
begin
--declare @variable int
--declare @summ decimal (10,2)
--declare @paymentType int
--set @variable = 14
--set @summ = 3116.80
--set @paymentType = 1

declare @pmtID int
declare @suppID int
declare @summtemp decimal (10,2)
declare @suppOrderID int 
set nocount on

if (isnumeric(@variable) = 0 or isnumeric(@summ)=0 or isnumeric(@paymentType)=0)
   begin print 'Please check your enter data (Non numeric)' return end

if not exists (select TypeID from PaymentTypes where TypeID = @paymentType)
   begin print 'Please enter rigth payment type from 1 till 4' return end

-- insert payment by SuppOrderID
if exists (select SuppOrderID from SuppOrders where SuppOrderID = @variable) -- check if variable is an order number
   begin
       if( (select PmtID from SuppOrders where SuppOrderID = @variable) not like 'None')
	      begin print 'This SuppOrder already paid. Please pick another one. ' return end

	   if(@summ != (select TotalSumm from SuppOrders where SuppOrderID = @variable))
	      begin print 'Please enter exactly summ of this order, else please make payment by Supplier ID ' return end

	   select @suppId = SupplierID from SuppOrders where SuppOrderID = @variable
	  
	  insert into PaymentsToSuppliers ([SupplierId],[Summ],[PaymentTypeID])
	          values (@suppId,@summ,@paymentType) ;
	   select  @pmtID = max(PaymentID) from PaymentsToSuppliers 
	   update SuppOrders set PmtID = @pmtID where suppOrderID = @variable
       return
   end
   
-- insert payment by SuppID ( payment will be insered to teh most older SuppOrderID)
-- @variable - supplier ID 
if not exists (select SuppID from Suppliers where SuppID=@variable)
    begin print 'Please check number of SupplierID and try again ' return end
if ( (select sum(TotalSumm) from SuppOrders where SupplierID=@variable ) -- supplier balance
		           = (select sum(Summ) from PaymentsToSuppliers where SupplierID=@variable))
    begin print 'Balance with current supplier is 0. This system does not provide for prepayment. ' return end


insert into PaymentsToSuppliers ([SupplierId],[Summ],[PaymentTypeID])  -- insert payment 
	          values (@variable,@summ,@paymentType) ;  
select  @pmtID = max(PaymentID) from PaymentsToSuppliers -- get paymentID 

while (@summ > 0 ) -- entering summs for non paid orders
    begin
	   if  not exists ( select SupplierID from SuppOrders where PmtID like 'None' and SupplierID = @variable) -- check if summ of all ordres equals to all payments
	       begin
		       set @summtemp =  (select sum(TotalSumm) from SuppOrders where SupplierID=@variable ) -- supplier balance
		           - (select sum(Summ) from PaymentsToSuppliers where SupplierID=@variable)  
                print 'Your payment was recieved. Current Balance with this supplier include this payment is '  + cast(@summtemp as varchar(10))
                --print @summtemp
			    return
	       end 
	   select @suppOrderID = min(SuppOrderID) from SuppOrders where PmtID like 'None' and SupplierID = @variable -- first order with 'None'
       select @summtemp = TotalSumm  from SuppOrders where SuppOrderID = @suppOrderID -- get summ of this order 
		     
	   update SuppOrders set PmtID = @pmtID where suppOrderID = @suppOrderID
	   set @summ = @summ - @summtemp
	end -- end of while 

set @summtemp =  (select sum(TotalSumm) from SuppOrders where SupplierID=@variable ) -- supplier balance
		           - (select sum(Summ) from PaymentsToSuppliers where SupplierID=@variable)  
                print 'Your payment was recieved. Current Balance with this supplier include this payment is '  + cast(@summtemp as varchar(10))
               -- print @summtemp
set nocount off
end -- end of procedure 
go

--***********************************************************************************************
