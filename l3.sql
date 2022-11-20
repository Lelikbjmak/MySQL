drop database if exists L3;

CREATE DATABASE L3;

USE L3;

CREATE TABLE manuf (
IDM int PRIMARY KEY,  
name varchar(20),  
city varchar(20));

INSERT INTO manuf VALUES 
(1,'Intel','Santa Clara'),
(2,'AMD','Santa Clara'),
(3,'WD','San Jose'),
(4,'seagete','Cupertino'),
(5,'Asus','Taipei'),
(6,'Dell','Round Rock');

CREATE TABLE cpu (
IDC int PRIMARY KEY ,
IDM int,
Name varchar(20),
clock decimal(5,2));

INSERT INTO cpu VALUES 
(1,1,'i5',3.20),
(2,1,'i7',4.70),
(3,2,'Ryzen 5',3.20),
(4,2,'Ryzen 7',4.70),
(5,NULL,'Power9',3.50);

CREATE TABLE hdisk (
IDD int PRIMARY KEY,
IDM int,
Name varchar(20),
type varchar(20),
size int);

INSERT INTO hdisk VALUES 
(1,3,'Green','hdd',1000),
(2,3,'Black','ssd',256),
(3,1,'6000p','ssd',256),
(4,1,'Optane','ssd',16);

CREATE TABLE nb (
IDN int PRIMARY KEY,
IDM int,
Name varchar(20),
IDC int,
IDD int);

INSERT INTO nb VALUES 
(1,5,'Zenbook',2,2),
(2,6,'XPS',2,2),
(3,9,'Pavilion',2,2),
(4,6,'Inspiron',3,4),
(5,5,'Vivobook',1,1),
(6,6,'XPS',4,1);

#3 неявное соединение
select * from manuf, cpu;  -- for each field add each filed from 2nd table

#4 соединений с условием wherer
select * from manuf, cpu where manuf.IDM = cpu.IDM;

#5 inner join
select * from manuf as M
join cpu as C ON M.IDM = C.IDM;

#6 Left Join
select * from manuf as M
left join cpu as C ON M.IDM = C.IDM;

#7 right join
select * from manuf as M
right join cpu as C ON M.IDM = C.IDM;

#8 cross join
select * from manuf as M
cross join cpu as C ON M.IDM = C.IDM;

#9 disk model and manufacturer of it
select M.Name, D.name from hdisk as D
inner join manuf as M on D.IDM = M.IDM;

select * from manuf;
select * from cpu;
select * from nb;


#10 processor + manufacturer
select M.name, C.name from manuf as M
right join cpu as C on M.IDM = C.IDM;

#11 laptops without manuf info in DB 
select L.name from nb as L 
left join manuf as M on L.IDM = M.IDM where M.IDM is null;

#12 laptop manufacturer of laptop + cpu + disk
select M.name as manuf, L.name as model, C.name as cpu, D.name as disk from nb as L
left join manuf as M on L.IDM = M.IDM
left join cpu as C on L.IDC = C.IDC
left join hdisk as D on L.IDD = D.IDD
order by M.name;

#13 laptot manuf 
select L.name as laptop, M.name as manuf, C.name as cpu, MM.name  as cpumanuf, D.name as disk, MMM.name as diskmanuf from nb as L
left join manuf as M on L.IDM = M.IDM
left join cpu as C on L.IDC = C.IDC
left join manuf as MM on C.IDM = MM.IDM
left join hdisk as D on L.IDD = D.IDD
left join manuf as MMM on D.IDM = MMM.IDM;


#14 all manuf and cpu they're producing 
select M.name as manuf, C.name from manuf as M 
left join cpu as C on C.IDM in (M.IDM)
union select IDM as manuf, name from cpu where IDM is null; 


#15 manuf which produce several types of gooses ??
select distinct M.name from manuf as M
right join cpu as C on C.IDM = M.IDM
right join hdisk as D on D.IDM = M.IDM
left join nb as L on L.IDM = M.IDM;


#15
select name from manuf where IDM in(
select IDM from cpu
where IDM in (select IDM from nb)) or IDM in(select IDM from cpu where IDM in (select IDM from hdisk)) or IDM in (select IDM from hdisk where IDM in (select IDM from nb)) ;



select * from cpu;
select * from nb;
select * from manuf;
