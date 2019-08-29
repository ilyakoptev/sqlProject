

use PAG_Flowers_ver03
go
-----******* Insert New Customer Procedure *********------------------------

CREATE PROCEDURE DeleteCustomer 
@Customer varchar(10) -- custID,CRN,WorkName
as 
BEGIN
--declare @Customer varchar(10)
--set @Customer = 'ama' -- 571239012, 1001, ama // 32367884, OLG, 1016 

if not exists (select custID from Customers where custId like @customer or workname like @customer or crn like @customer)
   begin print 'Customer not exists or you enter a wrong name or number' return end

if exists ( select CustOrderID 
  from Customers as c join  CustomerOrders as co on c.custid=co.customerID 
  where  custID like @Customer or crn  like @Customer or workname like @Customer)
  begin print 'You can not delete this customer because he has at least one order' return end 
  else begin 
     begin try
       begin tran;
          DELETE FROM Customers WHERE  custID like @Customer or crn  like @Customer or workname like @Customer
        commit tran;
  end try
  begin catch
    print 'Something went wrong in deleting customer. Please try again'  
	rollback tran;
   end catch
	  
   end 
 end -- end of procedure *****************************
 go 

-- exec DeleteCustomer 1018;

-- drop procedure DeleteCustomer 

 --select * from Customers 

 -----------------------------------------------
--**********Add new customer ***********************************************-------------------

 CREATE PROCEDURE AddNewCustomer
@CRN varchar (15),
@WorkName char(5) ,
@Company Nvarchar(20),
@ContactName Nvarchar(50),
@Telephone Nvarchar(25),
@ContactName2 Nvarchar(50) ,
@Telephone2 varchar (25),
@Address Nvarchar(50),
@City Nvarchar(30),
@Country Nvarchar(20),
@Email varchar(50),
@CategoryID int 
as 

BEGIN -- procedure BEGIN 

declare @EmployeeId int
declare @flag int
declare @printmsg nvarchar(30)
declare @printmessage varchar (60)
declare @count int

set @EmployeeId = 0
set @count = 1 


--- check CRN --- *************************************************************----
if (LEN(@CRN) < 7 or LEN(@CRN) > 13 ) begin print 'Please enter rigth CRN with 7-13  digits , if shoter than 7 type 0 insteed' return end 
   else begin -- begin else 
   while (@count <= LEN(@CRN))
      begin -- begin while 
	     if (substring(@CRN,@count,1) between '0' and '9') begin set @count=@count+1 end
		 else begin print 'Please Enter a CRN as numeric!' return end
	  end -- end while 
	  end -- end else
---------------**********************************---------------------------
set @count= 1  

--- check WorkName and Uppercase --- 
set @WorkName = UPPER (@WorkName) 

--print 'Change to Upper ' + @workname
---check format ***********************************************

--set @flag = substring(@Workname,2,1)  -- check if name have '-' symbol inside for add right manager name 
if (LEN(@WorkName)<2 or LEN(@Workname) >5) 
   begin print 'WorkName must have at between 2 and 5 Letters' return end 
   else  if ( LEN(@Workname)>4 and substring(@Workname,2,1) not like '-' ) begin 
        print 'WorkName must have maximum 4 letters or format X-XXX if customers belong to one of the managers'   return end 

 -- print '@flag after first check ' + cast(@flag as varchar(2)) + cast(LEN(@Workname)as varchar(2))  + @Workname

----check WorkName ------------------------------

while (LEN(@WorkName) <= 5 and @count <= LEN(@WorkName))
      begin
	     if @count=2 begin set @count=@count+1 continue end
		 else 
		      if (substring(@WorkName,@count,1) like '%[A-Z]%' or substring(@WorkName,@count,1) between '0' and '9')
			      begin 
				       -- print '@Count =' + cast(@count as varchar(2)) + 'Letter in check while = ' + substring(@WorkName,@count,1) 
					   set @count=@count+1
					   end
		      else begin print 'Please Enter a correct WorkName in format XXX or X-XXX!' return end
	  end

----check the contact name if it alphabetic **********************************---------------
set @count = 1
if(LEN(@ContactName)<2) begin print 'Contact name is too short' return end -- check if more 2 letter
set @ContactName = lower(@ContactName)
while ( @count <= LEN(@ContactName))
      begin
	     if (substring(@ContactName,@count,1) like '%[a-z]%') begin set @count=@count+1 end
		 else begin print 'Please Enter a right contact name with english letters!' return end
	  end

 -- set contact name with big first letter
set @ContactName = concat(upper(Left(@ContactName,1)),right(@ContactName,(len(@ContactName)-1)))


--print 'first letter ' + @sfletter + ' big first letter ' + @bfletter + 'Contact name ' + @ContactName
---**********check telephone number ***************************************************

set @count=2 

set @Telephone = REPLACE(@Telephone, ' ', '') -- delete all spaces in telephone number
set @Telephone = REPLACE(@Telephone, '(', '') -- delete all "("
set @Telephone = REPLACE(@Telephone, ')', '') -- delelte all ")"
set @Telephone = REPLACE(@Telephone, '-', '') -- delete all "-" 


if ( LEN(@Telephone) < 10 or LEN(@Telephone) > 23) 
     begin print ' Please enter a right telephone number in format +xxxxxxxxxxxx with country code' return end 
if (left(@Telephone,1) not like '+') 
     begin set @Telephone = CONCAT('+',@Telephone) end
	 
while (@count <= LEN(@Telephone))
      begin
	     if (substring(@Telephone,@count,1) between '0' and '9') begin set @count=@count+1 end
		 else begin print 'Please enter a right telephone number in format +xxxxxxxxxxxx with country code !' return end
	  end

--******* check Name2 and Telephone2 ************************

if (@ContactName2 is not null and @ContactName2 not like '' and @ContactName2 not like ' ')
   begin -- begin main if 
   set @count = 1
      if(LEN(@ContactName2)<2) begin print 'Contact name 2 is too short' return end -- check if more 2 letter
         set @ContactName2 = lower(@ContactName2)
         while ( @count <= LEN(@ContactName2))
              begin
	           if (substring(@ContactName2,@count,1) like '%[a-z]%') begin set @count=@count+1 end
		       else begin print 'Please Enter a right contact name with english letters!' return end
	          end
   set @ContactName2 = concat(upper(Left(@ContactName2,1)),right(@ContactName2,(len(@ContactName2)-1)))
   end -- end main if 

 if ( @Telephone2 is not null and @Telephone2 not like '' and  @Telephone2 not like ' ')  -- check if second telephone is not null 
    begin -- main begin 
	set @count=2  -- check from second digit because first digit must be + 
	set @Telephone2 = REPLACE(@Telephone2, ' ', '') -- delete all spaces in telephone number
    set @Telephone2= REPLACE(@Telephone2, '(', '') -- delete all (
    set @Telephone2 = REPLACE(@Telephone2, ')', '') -- delelte al )
    set @Telephone2 = REPLACE(@Telephone2, '-', '') -- delete all - 


    if ( LEN(@Telephone2) < 10 or LEN(@Telephone2) > 23) begin print ' Please enter a right telephone number in format +xxxxxxxxxxxx with country code' return end 
    if (left(@Telephone2,1) not like '+') -- add + to telephone number if not exists
      begin set @Telephone2 = CONCAT('+',@Telephone2) end
	 
      while (@count <= LEN(@Telephone2))
      begin
	     if (substring(@Telephone2,@count,1) between '0' and '9') begin set @count=@count+1 end
		 else begin print 'Please enter a right telephone number 2 in format +xxxxxxxxxxxx with country code !' return end
	  end
	  end  -- main end 
 --********** check city name ***********************************************

set @count = 1
if(LEN(@City)<2) begin print 'City name is too short' return end -- check if more 2 letter
set @City = lower(@City)
while ( @count <= LEN(@City))
      begin
	     if (substring(@City,@count,1) like '%[a-z]%') begin set @count=@count+1 end
		 else begin print 'Please Enter a right city name with english letters!' return end
	  end
 
set @City = concat(upper(Left(@City,1)),right(@City,(len(@City)-1)))
--*********check the country name *****************************

set @count = 1
if(LEN(@Country)<2) begin print 'Country name is too short' return end -- check if more 2 letter
set @Country = lower(@Country)
while ( @count <= LEN(@Country))
      begin
	     if (substring(@Country,@count,1) like '%[a-z]%') begin set @count=@count+1 end
		 else begin print 'Please Enter a right Country name with english letters!' return end
	  end
 
set @Country = concat(upper(Left(@Country,1)),right(@Country,(len(@Country)-1)))


---***********check e-mail address ******************--------------------------------

set @Email = lower(@Email)
if (len(@Email)< 9 or CHARINDEX('@', @Email)<4) begin print 'Please insert valid e-mail' return end
    
set @count = 1
set @flag = 0 
while  (@count <= len(@Email)) begin
     
	   if (substring(@Email,@count,1) not like '@' and substring(@Email,@count,1) not like '.' and substring(@Email,@count,1) not like '%[a-z]%' and substring(@Email,@count,1) not between '0' and '9') 
	   begin print 'Please enter valid e-mail - Dont use special symbols'
	   return end
	   else set @count=@count+1 end
set @count = 1

if (substring(@Email,@count,1) like '%[a-z]%' or substring(@Email,@count,1)  between '0' and '9') 
	begin -- main begin
	  set @count=@count+1  
     
	-- print 'Check first if ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
	 
	 while (@count <= len(@Email)) 
      begin -- while begin
	     --print 'Main While ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
		
		 if (substring(@Email,@count,1) like '@' and @flag = 0 )  
	       begin
		     set @flag = 1 
			 set @count=@count+1
			   --print 'Found @ ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
			   if (substring(@Email,@count,1) like '%[a-z]%' or substring(@Email,@count,1)  between '0' and '9')
			     begin  
				 set @count=@count+2 
				 -- print 'After Found @ ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1) 
				 continue end
			   else begin print 'Please enter a valid E-mail @...' return end
			 			 
		   end
		  else begin -- else 11
		       --  print 'Main Else 11 ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
				 if (@flag = 0) begin set @count=@count+1 continue end 
		           else -- flag =1 
				       begin --begin else flag =1
     
		              -- print 'Search ...  ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
			     -----
				   while (@count <= len(@Email)-2) 
				     begin 
			           if (substring(@Email,@count,1) not like '.' and substring(@Email,@count,1) not like '%[a-z]%' and substring(@Email,@count,1) not between '0' and '9') 
					       begin print 'Please enter a valid E-mail @@...' return end
					   if (substring(@Email,@count,1) like '.' ) 
					        begin 
							    set @flag = 2
								set @count = @count + 1
								-- print 'Found ...  ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
								break
							end
					   else set @count = @count + 1
					 end 
					 -----
			       end -- end else flag = 1
               
	         end -- else 11
	       set @count = @count + 1
		
		   end -- while end
	   if (@flag !=2 ) begin print 'Please enter a valid e-mail  ' return end
	end -- main end 
  else begin print 'Please insert valid e-mail (first letter)' return end 

  ---******** check category ID **********

  if (@categoryID !=1 and @categoryID !=2) begin print 'Enter rigth CategoryID (1-Flowers, 2-Herbs)' print @categoryID return end
 
-- add employeeId per customer name -----------*********************************************---------------

 if (substring(@Workname,2,1) not like '-')
     begin set @EmployeeId = 1 end
	 else  
          if (left(@Workname,1) like 'A') 
               begin set @printmsg =  'Andrey'  set @EmployeeId = 4 end 
			   else if (left(@Workname,1) like 'S') 
                    begin set @printmsg = 'Sergey'  set @EmployeeId = 2 end 
					else if  (left(@Workname,1) like 'O') 
                    begin set @printmsg = 'Olga'  set @EmployeeId = 3 end    
          else begin set @printmsg = 'Error' end 

 --************** Check CRN and wokrname in database ********************
  
  if ((select count(CRN) from Customers where CRN like @CRN) >= 1)
        begin
		   print 'Customer with CRN ' + @CRN + ' already exist. Please check CRN or customer already exists. ' return 
		end
         
  
  if ((select count(workname) from Customers where workname like @WorkName) >= 1)
        begin
		   print 'Customer with workname ' + @WorkName + ' already exists. Please pick another name. ' return 
		end
         
--------**********************************************************-------------------------------


--print @CRN + ' ' + @WorkName + ' ' + @Company + ' ' + @ContactName + ' ' + @Telephone + ' ' + @ContactName2 + ' ' + @Telephone2 + ' ' + @Address + ' ' + @City + ' ' + @Country + ' ' + @Email + ' ' + cast(@EmployeeID as char(1))
--print @WorkName
--print @printmsg
 begin try
    begin tran;
    INSERT INTO Customers 
         ([CRN],[WorkName],[Company],[ContactName],[ContactName2], [Telephone], [Telephone2],[Address],[City],[Country],[Email],[EmployeeId],[CategoryID] )
    VALUES (@CRN,@WorkName,@Company,@ContactName,@ContactName2, @Telephone, @Telephone2,@Address,@City,@Country,@Email,@EmployeeId,@CategoryID)
    commit tran;
end try
begin catch
    print 'Somethight went wrong in insert new customer, please try again' 
	rollback tran;
end catch
 
 --print 'Thank you for registering a new customer ' + @Workname + '. Your manager is ' + @printmsg + '.'

END; -- procedure END ********************************************************
go

--drop PROCEDURE AddNewCustomer  ;

--EXEC AddNewCustomer  '323678846','DEL','Delongia ','MAX','7 ( 952)674- 33-98','Sergey','7 ( 952)674- 98-98','5 ','Moscow','russia','samdavid@gmail.com',1;
--go

--select * from Customers 


--000000000000000000**********************************0000000000000000000000000
-- ******* ******
-- *	   *	 *
-- ***     *     *
-- *       *     *
-- ******* ******
------------8888888888888***************************---------------------------

use PAG_Flowers_ver03
go

-- *********************Edit Customer procedure ********************************

 CREATE PROCEDURE EditCustomer 

@Customer varchar (10),
@column char(20) ,
@Value Nvarchar(50)

as 

BEGIN -- procedure BEGIN 

--declare @Customer varchar (10)
--declare @column varchar(30) 
--declare @Value Nvarchar(50)

declare @EmployeeId int
declare @CustID int
declare @flag int
declare @printmsg nvarchar(30)
declare @printmessage varchar (60)
declare @count int

--set @Customer = 'OLG'  -- customer number or CRN or workName
--set @column = 'Country' -- column to change 
--set @Value = 'Ho5llnad' -- new value 


set @EmployeeId = 0
set @count = 1 

if not exists (select custID from Customers where custId like @customer or workname like @customer or crn like @customer)
 begin print 'Customer not exists or you enter a wrong name or number' return end
	
   -- set custID for current customer for follow operations 
 select @CustID = CustID from Customers  where custID like @Customer or crn  like @Customer or workname like @Customer
  
	   -- check if column to update is exists in current table 

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = @column
          AND Object_ID = Object_ID('dbo.Customers'))
BEGIN
   begin print 'There is not such option. Please check what field you want to update and try again ' return end 
END
  --else print 'exists'


if (@column='CRN') 
   begin
   	--- check CRN --- *************************************************************----
	if (LEN(@Value) < 7 or LEN(@Value) > 13 ) begin print 'Please enter rigth CRN with 7-13  digits , if shoter than 7 type 0 insteed' return end 
	 else begin -- begin else 
	 while (@count <= LEN(@Value))
		  begin -- begin while 
		   if (substring(@Value,@count,1) between '0' and '9') begin set @count=@count+1 end
			 else begin print 'Please Enter a CRN as numeric!' return end
		  end -- end while 
	 end -- end else
---------------**********************************---------------------------
    update Customers set CRN=@value where custID = @CustID 
    set @count= 1  
   end

else if (@column='WorkName') 
    begin 
     --- check WorkName and Uppercase --- 
      set @Value = UPPER (@Value) 
       ---check format ***********************************************

	if (LEN(@Value)<2 or LEN(@Value) >5) 
	 begin print 'WorkName must have at between 2 and 5 Letters' return end 
		else  if ( LEN(@Value)>4 and substring(@Value,2,1) not like '-' ) begin 
		  print 'WorkName must have maximum 4 letters or format X-XXX if customers belong to one of the managers'   return end 
		----check WorkName ------------------------------
		while (LEN(@Value) <= 5 and @count <= LEN(@Value))
		    begin
			     if @count=2 begin set @count=@count+1 continue end
				 else 
				      if (substring(@Value,@count,1) like '%[A-Z]%' or substring(@Value,@count,1) between '0' and '9')
					      begin 
						       -- print '@Count =' + cast(@count as varchar(2)) + 'Letter in check while = ' + substring(@WorkName,@count,1) 
							   set @count=@count+1
							   end
				   else begin print 'Please Enter a correct WorkName in format XXX or X-XXX!' return end
			 end -- end cheking workname
      update Customers set WorkName=@value where custID = @CustID 
	     
   end -- end update workName 
	
-- update Company name 
else if (@column='Company')	
     begin
	   update Customers set Company=@value where custID = @CustID 
	 end 
-- update Contact name 	 
 else if (@column='ContactName')
    begin 
	 		----check the contact name if it alphabetic **********************************---------------
		set @count = 1
		if(LEN(@Value)<2) begin print 'Contact name is too short' return end -- check if more 2 letter
		set @Value = lower(@Value)
		while ( @count <= LEN(@Value))
			  begin
			    if (substring(@Value,@count,1) like '%[a-z]%') begin set @count=@count+1 end
				 else begin print 'Please Enter a right contact name with english letters!' return end
			 end
		set @Value = concat(upper(Left(@Value,1)),right(@Value,(len(@Value)-1)))
		update Customers set ContactName=@value where custID = @CustID 
	end 

else if (@column='Telephone')	
     begin 
	 
		---**********check telephone number ***************************************************
		set @count=2 

		set @Value = REPLACE(@Value, ' ', '') -- delete all spaces in telephone number
		set @Value = REPLACE(@Value, '(', '') -- delete all (
		set @Value = REPLACE(@Value, ')', '') -- delele all )
		set @Value = REPLACE(@Value, '-', '') -- delete all - 
		
		if ( LEN(@Value) < 10 or LEN(@Value) > 23) begin print ' Please enter a right telephone number in format +xxxxxxxxxxxx with country code' return end 
		if (left(@Value,1) not like '+') 
		  begin set @Value = CONCAT('+',@Value) end
	 
		while (@count <= LEN(@Value))
		    begin
			    if (substring(@Value,@count,1) between '0' and '9') begin set @count=@count+1 end
				 else begin print 'Please enter a right telephone number in format +xxxxxxxxxxxx with country code !' return end
			 end
       update Customers set Telephone=@value where custID = @CustID 
	end 
else if (@column like 'ContactName2')
    begin
	 	----check the contact name if it alphabetic **********************************---------------
		set @count = 1
		if(LEN(@Value)<2) begin print 'Contact name is too short' return end -- check if more 2 letter
		set @Value = lower(@Value)
		while ( @count <= LEN(@Value))
			  begin
			    if (substring(@Value,@count,1) like '%[a-z]%') begin set @count=@count+1 end
				 else begin print 'Please Enter a right contact name with english letters!' return end
			 end
		set @Value = concat(upper(Left(@Value,1)),right(@Value,(len(@Value)-1)))
	 update Customers set ContactName2=@value where custID = @CustID 
	end 
else if (@column='Telephone2')	
     begin 
	 
		---**********check telephone number ***************************************************
		set @count=2 

		set @Value = REPLACE(@Value, ' ', '') -- delete all spaces in telephone number
		set @Value = REPLACE(@Value, '(', '') -- delete all (
		set @Value = REPLACE(@Value, ')', '') -- delele all )
		set @Value = REPLACE(@Value, '-', '') -- delete all - 
		
		if ( LEN(@Value) < 10 or LEN(@Value) > 23) begin print ' Please enter a right telephone number in format +xxxxxxxxxxxx with country code' return end 
		if (left(@Value,1) not like '+') 
		  begin set @Value = CONCAT('+',@Value) end
	 
		while (@count <= LEN(@Value))
		    begin
			    if (substring(@Value,@count,1) between '0' and '9') begin set @count=@count+1 end
				 else begin print 'Please enter a right telephone number in format +xxxxxxxxxxxx with country code !' return end
			 end
       update Customers set Telephone2=@value where custID = @CustID 
	end 

 else if (@column='Address')	
     begin
	   update Customers set [Address]=@value where custID = @CustID 
	 end 

else if (@column='City')
    begin
       --********** check city name ***********************************************
	   set @count = 1
		if(LEN(@Value)<2) begin print 'City name is too short' return end -- check if more 2 letter
		set @Value = lower(@Value)
		while ( @count <= LEN(@Value))
			begin
			  if (substring(@Value,@count,1) like '%[a-z]%') begin set @count=@count+1 end
				 else begin print 'Please Enter a right city name with english letters!' return end
			 end
		set @Value = concat(upper(Left(@Value,1)),right(@Value,(len(@Value)-1)))
		--*********check the country name *****************************
	update Customers set City=@value where custID = @CustID 
	end 

else if (@column='Country')
   begin
       set @count = 1
		if(LEN(@Value)<2) begin print 'Country name is too short' return end -- check if more 2 letter
		set @Value = lower(@Value)
		while ( @count <= LEN(@Value))
			  begin
			    if (substring(@Value,@count,1) like '%[a-z]%') begin set @count=@count+1 end
				 else begin print 'Please Enter a right Country name with english letters!' return end
			 end
		set @Value = concat(upper(Left(@Value,1)),right(@Value,(len(@Value)-1)))
    update Customers set Country=@value where custID = @CustID 
   end 

else if (@column='EmployeeID') -- change EmploeerID 
     begin 
	     if exists (select EmployeeId from Employees where EmployeeId = @value)
		    update Customers set EmployeeId=@value where custID = @CustID 
		 else
		    begin print 'Please check EmployeeId and try again' return end
	 end 
else if (@column='PtmDelay') -- change payment delay 
     begin 
	     if (@value%30=0)
		    update Customers set PtmDelay=@value where custID = @CustID 
		 else
		    begin print 'Please enter payment delay in format 30/60/90' return end
	 end 

else if (@column='Email')
  begin
    declare @email varchar (50) 
	set @email = @value 
---***********check e-mail address ******************--------------------------------

set @Email = lower(@Email)
if (len(@Email)< 9 or CHARINDEX('@', @Email)<4) begin print 'Please insert valid e-mail' return end
    
set @count = 1
set @flag = 0 
while  (@count <= len(@Email)) begin
     
	   if (substring(@Email,@count,1) not like '@' and substring(@Email,@count,1) not like '.' and substring(@Email,@count,1) not like '%[a-z]%' and substring(@Email,@count,1) not between '0' and '9') 
	   begin print 'Please enter valid e-mail - Dont use special symbols'
	   return end
	   else set @count=@count+1 end
set @count = 1

if (substring(@Email,@count,1) like '%[a-z]%' or substring(@Email,@count,1)  between '0' and '9') 
	begin -- main begin
	  set @count=@count+1  
     
	-- print 'Check first if ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
	 
	 while (@count <= len(@Email)) 
      begin -- while begin
	     --print 'Main While ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
		
		 if (substring(@Email,@count,1) like '@' and @flag = 0 )  
	       begin
		     set @flag = 1 
			 set @count=@count+1
			   --print 'Found @ ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
			   if (substring(@Email,@count,1) like '%[a-z]%' or substring(@Email,@count,1)  between '0' and '9')
			     begin  
				 set @count=@count+2 
				 -- print 'After Found @ ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1) 
				 continue end
			   else begin print 'Please enter a valid E-mail @...' return end
			 			 
		   end
		  else begin -- else 11
		       --  print 'Main Else 11 ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
				 if (@flag = 0) begin set @count=@count+1 continue end 
		           else -- flag =1 
				       begin --begin else flag =1
     
		              -- print 'Search ...  ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
			     -----
				   while (@count <= len(@Email)-2) 
				     begin 
			           if (substring(@Email,@count,1) not like '.' and substring(@Email,@count,1) not like '%[a-z]%' and substring(@Email,@count,1) not between '0' and '9') 
					       begin print 'Please enter a valid E-mail @@...' return end
					   if (substring(@Email,@count,1) like '.' ) 
					        begin 
							    set @flag = 2
								set @count = @count + 1
								-- print 'Found ...  ' + cast(@count as varchar(2)) + ' ' + cast(@flag as varchar(2)) + ' ' + substring(@Email,@count,1)
								break
							end
					   else set @count = @count + 1
					 end 
					 -----
			       end -- end else flag = 1
               
	         end -- else 11
	       set @count = @count + 1
		
		   end -- while end
	   if (@flag !=2 ) begin print 'Please enter a valid e-mail  ' return end
	end -- main end 
  else begin print 'Please insert valid e-mail (first letter)' return end 
  update Customers set Country=@value where custID = @CustID 
end --- e-mail 


END; -- procedure END ********************************************************
go

--exec EditCustomer DEL, ContacTName, Anton;
--go
--drop procedure EditCustomer
--go
--select * from customers 	
	
 