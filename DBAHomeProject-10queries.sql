


use PAG_Flowers_ver03
go

--***********************************************************************************
create procedure CustomerBalance  -- CustID/WorkName/CRN , month (in number or 0 for all), year (XXXX)
@customer varchar(10),
@month int,
@year int
as
begin
-- declare @Customer varchar(10)
--declare @month int 
--declare @year int

declare @custID int
declare @tabletemp table (
         CustomerID int,
		 WorkName varchar(5),
		 InvoiceID int,
		 [Invoice Date] date,
		 [For Year] int,
		 [Invoice Total] decimal(10,2),
		 [Payment Date] varchar(15),
		 [Payment] decimal(10,2),
		 [Balance] decimal (10,2))

--set @Customer = 'ext' -- 571239012, 1001, ama // 32367884, OLG, 1016 
--set  @month = 0
--set  @year = 2018

-- check if customer exists 
if not exists (select custID from Customers where custId like @customer or workname like @customer or crn like @customer)
 begin print 'Customer not exists or you enter a wrong name or number' return end

    -- set custID for current customer for follow operations 
 select @CustID = CustID from Customers  where custID like @Customer or crn  like @Customer or workname like @Customer
 
 -- insert to tabletemp without sorting by input date 
 insert into @tabletemp (CustomerID, WorkName , InvoiceID ,
      [Invoice Date] , [For Year] , [Invoice Total] , [Payment Date],[Payment] ,[Balance])
	  select  [CustomerID], [WorkName], [InvoiceID], [InvoiceDate], 
	         year(InvoiceDate) as [For Year],
	         [TotalSum] as [Invoice Total], 
			 iif ([Payment Date] is null,'Not paid',cast([Payment date] as varchar(20))) as [Payment date] , 
			 iif ([Summ] is null, 0, [Summ]) as [Paid], 
			 iif (([Summ] - [Totalsum]) is null, [TotalSum],[Summ] - [Totalsum] ) as [Balance]
           from Customers as c join CustomerOrders as co on c.CustID=co.CustomerID
	       join Custinvoices as ci on co.custOrderID= ci.OrderId
	       left join Receipts as r on ci.invoiceID=r.invoiceNumber
	       where CustomerID = @CustID 

-- select * from @tabletemp
--- if month and year both are 0 -> output all records for this customer include total balance for all period 
 if (@month=0 and @year=0) begin
     select CustomerID, WorkName , InvoiceID ,
            [Invoice Date] , [For Year] , [Invoice Total] , [Payment Date],[Payment] ,
	        (select sum(balance) from @tabletemp where aaa.[Invoice Date] >= [Invoice Date]) as [Final Balance]
	 from @tabletemp as aaa 
    return
	end

-- if month and year both are not 0 -> check inputs year and month 
 if ( isnumeric(@year)=0 or isnumeric(@month)=0 or (@month not between 0 and 12) or (@year not between year((select min(InvoiceDate) from CustInvoices)) and year(getdate())) ) 
    begin print 'Please enter right dates' return end
	-- for all months include total balance for this period 
 if (@month= 0 )
    begin 
      select CustomerID, WorkName , InvoiceID ,
            [Invoice Date] , [For Year] , [Invoice Total] , [Payment Date],[Payment] ,
	        (select sum(balance) from @tabletemp where aaa.[Invoice Date] >= [Invoice Date] and year([Invoice Date])=@year) as [Final Balance]
	  from @tabletemp as aaa
	       where year([Invoice Date])=@year
	end
 else begin -- for special month and year 
      select CustomerID, WorkName , InvoiceID ,
            [Invoice Date] , [For Year] , [Invoice Total] , [Payment Date],[Payment] ,
	        (select sum(balance) from @tabletemp 
			 where aaa.[Invoice Date] >= [Invoice Date] and year([Invoice Date])=@year and month([Invoice Date])  = @month) as [Final Balance]
	  from @tabletemp as aaa
	       where year([Invoice Date])=@year and month([Invoice Date])  = @month
 	 end 	

end -- end fo procedure 
 go


-- **************************************************
create procedure CustomerFinalBalance  -- CustID/WorkName/CRN 
@customer varchar(10)
as
begin
declare @custID int
declare @result decimal(10,2)
 -- check if customer exists 
if not exists (select custID from Customers where custId like @customer or workname like @customer or crn like @customer)
 begin print 'Customer not exists or you enter a wrong name or number' return end
 -- set custID for current customer for follow operations 
 select @CustID = CustID from Customers  where custID like @Customer or crn  like @Customer or workname like @Customer
 
 if not exists (select CustOrderID from CustomerOrders where CustomerID = @custID)
    begin print 'No orders for this Customer yet.' return end

	 select @result = (sum(TotalSum)-sum(isnull(Summ,0))) from CustInvoices as ci join CustomerOrders as co on ci.OrderId=co.CustOrderID 
	              left join Receipts as r on r.InvoiceNumber=ci.InvoiceID
	              where CustomerID= @custID
   print 'Final balance for this customer is ' + cast(@result as varchar(10)) 
end -- end of procedure
go
-- **************************************************

-- Sales for specific product per special period per customer 

create procedure ProductSales -- productID, startDate, endDate, Customer (if value is 0 - get all)
@product varchar (20),
@startDate varchar(10),
@endDate varchar(10),
@customer varchar (10)

as
begin
--declare @product varchar (20)
--declare @startDate varchar(10)
--declare @endDate varchar(10)
--declare @customer varchar (10)
--set @product = 'eus'
--set @startDate = 0
--set @endDate = '2019-05-02'
--set @customer = 0
declare @custID int 
declare @custIDMax int
declare @productID int
--set @productID = 0 -- if entering product name


--check input fields  -- check if customer exists 

if (@customer like '0' )
  	select @CustID = min(CustID),@CustIDMax = max(CustID) from Customers  
else begin
      if not exists (select custID from Customers where custId like @customer or workname like @customer or crn like @customer)
          begin print 'Customer not exists or you enter a wrong name or number' return end
      select @CustID = CustID, @CustIDMax = CustID from Customers  where custID like @Customer or crn  like @Customer or workname like @Customer
    end 
 -- check if product exists in data base

if not exists (select ProductID from Products where ProductID like @product or ProductName like '%'+@product+'%' )
   begin print 'Product not exists or you enter a wrong name or number' return end
    else if exists (select ProductID from Products where ProductID like @product) 
	       select @productID = ProductID from Products where ProductID like @product -- set product ID if entered ProdID not name 

if (@startDate like 0) select @startDate= cast(min(InvoiceDate) as date) from CustInvoices
if (@endDate like 0) select @endDate= cast(max(InvoiceDate) as date) from CustInvoices

if (isdate(@startDate)=0 or isdate(@endDate) = 0)
    begin print 'Please Enter right dates' return end
	else begin 
	set @startDate = cast(@startDate as date)
	set @endDate = cast(@endDate as date) 
	end
select p.[ProductID] ,p.[ProductName], p.[Description],Qty as [Total QTY],datename(month,(InvoiceDate)) as [Month] ,year(InvoiceDate) as [Year] ,WorkName as Customer,Qty*UnitPrice as [Total Cost]
from Products as p join CustomersOrderDetails as od on p.ProductID=od.ProductId
     join CustomerOrders as co on co.CustOrderID=od.OrderId 
	 join Customers as c on c.CustID=co.CustomerID
	 join CustInvoices as ci on ci.OrderId=co.CustOrderID
     where (p.ProductID = @productID or ProductName like '%'+@product+'%') 
	 and (InvoiceDate between @startDate and @endDate) 
	 and (CustID between @CustID and @CustIDMax)
	 group by p.[ProductID] ,p.[ProductName], p.[Description],Qty,datename(month,(InvoiceDate)) ,year(InvoiceDate) ,WorkName ,Qty*UnitPrice 
	 order by p.ProductID
	          


end -- end of procedure
go
--**********************************************************************************************








select  CustomerID, WorkName, InvoiceID, InvoiceDate, TotalSum, ReceiptID, [Payment Date], Summ
    from Customers as c join CustomerOrders as co on c.CustID=co.CustomerID
	join Custinvoices as ci on co.custOrderID= ci.OrderId
	left join Receipts as r on ci.invoiceID=r.invoiceNumber
	where CustomerID = 1000 

select * from CustomerOrders where CustOrderID = 20014

select * from CustomersOrderDetails where OrderID = 20014 order by ProductID

select * from Products where productID in (3010,3013,3006,3004,3012)

select * from CustInvoices where OrderID = 20014

select * from SuppOrders where CustomerOrderID = 20014

select * from SuppOrderDetails where OrderID in (5039,5040,5041)





