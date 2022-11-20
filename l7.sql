-- ??? - Что такое транзакция? Как работает транзакция? Когда и для чего используют транзакции?
-- транзакция служит для согалсованности данных, т.е. выполнение нескольких запросов последовательно дург за другом, при нарушении одного из них происходит откат БД в предыдузий сейвпоинт
-- 'все или ничего'.
-- ??? - Что такое индексы? Как работают индексы? Какие бывают индексы?
-- спец объекты БД, которые позволяют существенно увеличить свкорость выполения запроса по поиску значений из таблиц БД, Отсортированные указателти на данные ил иже непосредственно сами данные

-- ----------------------------------------------------------------------------------------------------------------------------------------

use l5;

/* 	№1	Привести пример использования транзакции. Транзакция должна завершиться успешно. */

-- Решение:

-- max UID = 349
--  max BID = 1500
select * from books;

start transaction;
insert into bubuy value(1, 100, now());
insert into bubuy value(2, 200, now());
rollback;
commit;

DELIMITER //
create procedure TransactionExample(IDUF int, IDBF int, IDUS int, IDBS int)
begin
	
    	declare exit handler for sqlexception, sqlwarning -- foreign key error 1452
	begin
		SIGNAL SQLSTATE '45000'  
		SET MESSAGE_TEXT = 'Transaction rejected, rollback!';  
        rollback;
    end;
    
    start transaction;       
    insert into bubuy value(IDUF, IDBF, now());
	insert into bubuy value(IDUS, IDBS, now());
    commit;
    
end//
DELIMITER ;

drop procedure TransactionExample;

#success Transaction
call TransactionExample(1, 1, 2, 1);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* 	№2	Привести пример использования транзакции. Транзакция должна должна быть отклонена. */

-- Решение: 

#fail Transaction
call TransactionExample(500, 100, 501, 200);


-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№3 Создать таблицу "Buy", которая состоит из полей: ID - первичный ключ, авто заполняемое. IDB, IDU, TimeBuy
Создать уникальный составной индекс для IDB, IDU. Создать обычный индекс TimeBuy, обратный порядок. 
*/

-- Решение:

create table Buy(
ID int primary key auto_increment,
IDB int,
IDU int, 
TimeBuy datetime,
unique index IDB_IDU (IDB, IDU),
index TimeBuy (Timebuy desc),
constraint IDU_fk_Buy foreign key(IDU) references users(IDU),
constraint IDB_fk_Buy foreign key(IDB) references Books(IDB)
);

show create table Buy;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№4  Модифицировать таблицу "Buy", добавить поле для хранения стоимости покупки "Cost".*/

-- Решение:

alter table Buy add column Cost decimal(8,2);


-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Создать хранимую процедуру для добавления записи о покупке книги и подсчета итоговой цены книги с учетом всех скидок и предложений. Полученная стоимость записывается в поле "Cost". }

-- Решение:

DELIMITER //
create function bookPrice_with_user_discount(IDU int, IDB int)
returns decimal
deterministic
begin

	declare price decimal(8,2);
    set price = 0.00;

	set price = (select (B.price - B.price*(select discount_for_user(IDU))/100) from Books as B where B.IDB = IDB);

	return price;
    
end;//
DELIMITER ;

drop function bookPrice_with_user_discount;

select * from bubuy;
select * from books;

DELIMITER //
create procedure BookBuy(IDB int, IDU int)
begin
	
  --   declare exit handler for sqlexception
-- 	begin
-- 		SIGNAL SQLSTATE '45000'  
-- 		SET MESSAGE_TEXT = 'Adding book rejected'; 
--     end;
     
    insert into Buy(IDB, IDU, Timebuy, Cost) value(IDB, IDU, now(), (select bookPrice_with_user_discount(IDU, IDB)));
    
end;//
DELIMITER ;

drop procedure BookBuy;

call BookBuy(1,1);
select * from Buy;
select discount_for_user(1);
select * from books;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№5	Изменить триггер для таблицы USERS, который теперь должен срабатывать при изменении адреса почтового ящика.*/ 

-- Решение:

# with schemas...
# add if new.mail <> old.mail then insert(...)
select * from archiveusers;
update users set mail = 'test@dot.com' where IDU = 3;
select * from users;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№6	Для таблицы пользователей заменить пароль, который хранится в открытом виде, на тот же, но захешированный методом md5.*/

-- Решение:

update users set pass = md5(users.pass);  -- better + 'gfasgfv322atdf' - excess rubbish
#here our trigger to full archive table will be executed on all fileds
select * from users;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№7	Вывести количество и среднее значение стоимости книг, которые были просмотрены, но не разу не были куплены.*/

-- Решение:
select count(*) as count, avg(B.price) as avgprice from buview inner join Books as B using (IDB) where IDB not in(select IDB from bubuy);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№8	Вывести количество купленных книг, а также суммарную их стоимость для тем с кодом с 1 по 6 включительно.*/

-- Решение:

select T.theme, count(*) as count, sum(B.price) as sum from bubuy as BU inner join books as B using(IDB)inner join bt using(IDB) inner join theme as T using(IDT) where T.IDT <=6 group by T.theme;

-- check comics
-- select * from bt where IDT = 6;
-- select * from books where IDB = 940;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№9	Вывести Название книги, Имя автора, Логин покупателя для книг, которые были куплены в период с июня по август 2018 года включительно, написаны
 в тематике 'фэнтези' и 'классика', при условии, что число страниц должно быть от 700 до 800 включительно и цена книги меньше 500.*/

#create index theme on theme(theme);

-- Решение:
select * from bubuy as BU inner join
(select IDB, title, pages, price, group_concat(distinct ba.namea) as author ,group_concat(distinct T.theme) as theme from books as B left join bt using(IDB) left join ba using(IDB)
inner join theme as T using(IDT) where T.theme = 'фэнтези' or T.theme = 'классика' group by IDB) as B using(IDB) where B.pages>=700 and B.pages<=800 and B.price<500 and BU.Datetime between '2018-06-01 00:00:00' and '2018-08-31 23:59:59' group by (BU.IDB);
 
insert into bubuy value(1,356,'2018-07-13 11:26:10');

#---------------------------------------------------------------------------------------------------------------------------------------
/*	**{Создать таблицу «Авторы», где бы хранились имена авторов без повторений (Варианты Толстой Лев, Толстой Л.Н. и др. считать уникальными) и его ID. }	*/

-- Решение:


create table authors(
IDA int primary key auto_increment,
name varchar(45)
);

insert into authors(name) (select distinct namea from ba);

select * from authors;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	**{Создать новую таблицу «ВА» для связи таблиц «Книги» и «Авторы» через ID, и заполнить её.}	*/

-- Решение:

create table AB(
IDB int, 
IDA int, 
constraint IDB_fk_AB foreign key(IDB) references books(IDB),
constraint IDA_fk_AB foreign key(IDA) references authors(IDA)
);

select * from ba as B inner join authors as A on(A.name = B.namea);

insert into AB (select B.IDB, A.IDA from ba as B inner join authors as A on(A.name = B.namea));

select * from AB;
-- ----------------------------------------------------------------------------------------------------------------------------------------
