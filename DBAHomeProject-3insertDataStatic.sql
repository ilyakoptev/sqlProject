

-- insert the first information into the all tables 
 
 use PAG_Flowers_ver03 
 
INSERT INTO Categories ([CategoryID],[CategoryName])
VALUES (1,'Flowers'),
       (2,'Herbs');
go

 INSERT INTO JobPositions 
              ([JobPositionId], [JobName] )
VALUES (1,'Office Manager'),
       (2,'Sales Manager'),
	   (3,'Accounts'),
	   (4,'Drivers'),
	   (5,'Ceo');
	   go

 INSERT INTO Employees 
             ([EmployeeId],[Name],[Position],[Telephone],[Email])
 VALUES (1,'Office',1,'+97236792348','info@pag.co.il'),
        (2,'Sergey',2,'+79103432233','sergey@pag.co.il'),
		(3,'Olga',2,'+79163720918','olga@pag.co.il'),
		(4,'Andrey',2,'+790350030020','andrey@pag.co.il'),
		(5,'Alena',1,'+972506771209','alena@pag.co.il'),
		(6,'Vasya',1,'+972543807456','vasya@pag.co.il'),
		(99,'Philip',5,'+972543373000','ceo@pag.co.il'),
		(20,'Larisa',3,'+972548213409','larisa@pag.co.il'),
		(10,'Anatoly',4,'+972543807447','');

		go

 INSERT INTO Customers 
 ([CRN],[WorkName],[Company],[ContactName],[ContactName2], [Telephone], [Telephone2],[Address],[City],[Country],[Email],[EmployeeId],[CategoryID])
 VALUES ('571239012','AMA','Azalia','Evgeny',' ','+79031302020',' ',' ','Novgorod','Russia','azalia-ama@azalia-group.ru',1,1),
        ('571739403','AZ','Azalia','Boris',' ','+79031302010',' ',' ','Moscow','Russia','azalia-az@azalia-group.ru', 1,1),
		('571037482','CFL','CFL','Roman','Nikolay','+79163291122','+79039737612 ',' ','Moscow','Russia','roman@cfl.ru', 1,1),
		('571093727','EXT','Glameria','Exibar',' ','+79132105050',' ',' ','Moscow','Russia','order@glameria.ru', 1,1),
		('579739044','S-PRO','SPRO','Sergey',' ','+79112873412',' ',' ','Moscow','Russia','spro@mail.ru', 2,1),
		('578374022','S-KUR','Kurilova','Sergey',' ','+79217801923',' ',' ','Kursk','Russia','kurilova@mail.ru', 2,1),
		('574758393','ALAN','ALAN','Alan',' ','+79105238778',' ',' ','Moscow','Russia','alan1978@gmail.com', 1,1),
		('579484839','O-ONI','Onishenko','Tatiana',' ','+79103908912',' ',' ','Moscow','Russia','oni2003@mail.ru', 3,1),
		('573529362','A-SSA','Systema','Andrey',' ','+79862891210',' ',' ','Moscow','Russia','ssa@pagmanager.ru', 4,1),
		('571938578','KAT','Katerine','Katya',' ','+79183450912',' ',' ','Zelenograd','Russia','kat1978@mail.ru',1,2),
        ('572083647','ROM','Roman Fl','Roman',' ','+79034981265',' ',' ','Moscow','Russia','romflowers@gmail.com', 1,2),
		('570964638','YAL','Yakov','Yakov','','+79519862601',' ',' ','Moscow','Russia','yal357@mail.ru', 1,2),
		('578375843','RAZ','Reznik','Anatoly',' ','+79039879898',' ',' ','Tver','Russia','reznik1932@gmail.com', 1,2),
		('579739045','S-MAX','SMAX','Sergey',' ','+79112873412',' ',' ','Moscow','Russia','sergey@pag.com', 2,1),
		('578454022','S-LIT','SLIT','Sergey',' ','+79217801923',' ',' ','Lipetsk','Russia','sergey@pag.com', 2,1),
		('571874677','O-DOM','Flower house','Olga',' ','+79103908912',' ',' ','Moscow','Russia','florhouse@mail.ru', 3,1),
		('579564839','O-DSK','Dosk','Anton',' ','+79103904509',' ',' ','Moscow','Russia','dosck1999@gmail.com', 3,1),
		('573589362','A-GAL','Galant','Andrey',' ','+79862891210',' ',' ','Moscow','Russia','pagmanager@pag.com', 4,1);


go


INSERT INTO PaymentTypes([TypeId],[TypeName])
Values (1,'Cash'),(2,'Check'),(3,'Bank Transfer'),(4,'Credit Card');
  
  go

go
INSERT INTO Products
       ([ProductName],[Description],[MinOrder],[Unit],[ListPrice],[CategoryID])
    VALUES ('Lisiantus Eustoma','White','400','pcs',2.5,1),
	       ('Lisiantus Eustoma','Blue White','200','pcs',2.5,1),
		   ('Lisiantus Eustoma','Pink White','200','pcs',2.5,1),
		   ('Lisiantus Eustoma','Blue','200','pcs',2.5,1),
		   ('Lisiantus Eustoma','Pink','200','pcs',2.5,1),
		   ('Lisiantus Eustoma','Painted','100','pcs',2.9,1),
		   ('Aspidistra','70 cm','1500','pcs',1.5,1),
		   ('Aspidistra','80 cm','1000','pcs',1.6,1),
		   ('Ruscus','60 cm','2000','pcs',1,1),
		   ('Ruscus','70 cm','1500','pcs',1.2,1),
		   ('Ruscus','80 cm','600','pcs',1.8,1),
		   ('Aspagarus','70 cm','300','pcs',2.8,1),
		   ('Aspagarus','80 cm','200','pcs',2.9,1),
		   ('Aspagarus','Plumosus','500','pcs',1.9,1),
		   ('Pitosporum','70 cm','400','pcs',1.9,1),
		   ('Pitosporum','80 cm','200','pcs',2.2,1),
		   ('Mint','1 kg','10','kg',3,2),
		   ('Rocola','1 kg','10','kg',4,2),
		   ('Basil','1 kg','10','kg',4.5,2),
		   ('Red Basil','1 kg ','10','kg',5.2,2)   ;

 go
 


INSERT INTO Suppliers
        ([SuppName],[ContactName],[Telephone],[CategoryID])
 VALUES ('Buki Flowers LTD','Nadav','0543006776',1),
        ('Gyvat Prahim','Yuval','0504328545',1),
		('Yerukim','Yossi','0525870089',1),
		('Even Green','Shay','0548762310',1),
		('Moshe Askayo','Moshe','0543224545',1),
		('Hazan','Yuda','0506578888',1),
		('Yaniv','Yaniv','0501013921',2),
		('Izhak','Tomer','0525213021',2);
 go

 INSERT INTO SuppPricelist
         ([SuppId],[ProductId],[SuppPrice])
VALUES (10,3000,1.7),
       (10,3001,1.7),
	   (10,3002,1.7),
	   (10,3003,1.7),
       (10,3004,1.7),
	   (10,3005,1.8),
	   (11,3000,1.6),
	   (11,3001,1.6),
	   (11,3002,1.6),
	   (11,3003,1.6),
       (11,3004,1.6),
	   (11,3005,1.8),
	   (15,3006,0.6),
	   (15,3007,0.8),
	   (12,3008,0.3),
	   (12,3009,0.4),
	   (12,3010,0.5),
	   (10,3007,0.9),
	   (10,3009,0.5),
	   (10,3010,0.8),
	   (10,3013,0.5),
	   (14,3011,1.2),
	   (14,3012,1.3),
	   (10,3008,0.5),
	   (10,3011,1.4),
	   (10,3012,1.5),
	   (13,3010,0.8),
	   (13,3011,0.9),
	   (13,3012,1.0),
	   (13,3014,0.4),
	   (13,3015,0.5),
	   (16,3016,2.2),
	   (16,3017,3.2),
	   (16,3018,2.5),
	   (16,3019,4),
	   (17,3018,2.5),
	   (17,3019,4);
	  
	   
go	   
