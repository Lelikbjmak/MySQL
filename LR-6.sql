-- Переименовать название файла. Вместо "x" - номер группы. Фамилию указать латиницей. (shift + ctrl + S -> сохранить как)
-- Все решения должны быть оформлены в виде запросов, и записаны в этот текстовый файл (в том числе создание хранимых процедур, функций и т.д.).
-- Задания рекомендуется выполнять по порядку.  
-- Задания **{} - выполнять по желанию.
-- Проверить таблицу BUBuy, для поля IDU значения должны быть не более 350, для поля IDB около 1500. Если наоборот то выполнить запрос:
-- ALTER TABLE bubuy CHANGE COLUMN IDU IDB INT, CHANGE COLUMN IDB IDU INT;

-- ??? - Что такое представление (VIEW). Для решения каких задач применяется VIEW?

-- view - виртуальные таблицы для доступа к данным уже существующей таблицы (защищает данные, т.к предоставляет доступ тольков к части таблицы)

-- ??? - Что такое триггер, для каких задач его можно применять, какие ограничения применения есть в MySQL?

-- спец харнимая процедура для автоматического вызова при определенном условии( при срабатывании операций update, delete, insert над таблицей или view) 

-- ??? - Какие функции бывают в  MySQL, как их применять?

-- пользовательскте функции, хранимые функции и процедуры

-- ----------------------------------------------------------------------------------------------------------------------------------------
use l5;

/* 	№1 Создать таблицу для хранения просмотров книг зарегистрированными пользователями. BUView - состоит из двух полей IDB, IDU. 
	При создании таблицы прописать FOREIGN KEY */
-- Решение:

select * from users;

create table BUView(
IDB int,
IDU int,
Primary key(idu, idb),
constraint IDU_BUView_fk foreign key(IDU) references users(IDU) on delete cascade on update cascade,
constraint IDB_BUView_fk foreign key(IDB) references books(IDB) on delete cascade on update cascade
);

#create view BUView(IDU, IDB) as select IDU, IDB from bubuy;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№2 Создать таблицу для хранения закладок "BUMark", где пользователь может пометить страницу в купленной книге и оставить короткое 
	текстовое описание, важно также знать время создания закладки.		
    **{При создании таблицы прописать FOREIGN KEY к оптимальной таблице} */

-- Решение:

create table BUMark(
IDU int, 
IDB int,
page int,
description varchar(100),
date_of_describtion datetime,
primary key(IDU, IDB),
constraint IDU_BUMark_fk foreign key(IDU) references bubuy(IDU),
constraint IDB_BUMark_fk foreign key(IDB) references bubuy(IDB)
);


-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	**{Создать таблицу для специального предложения месяца "BStock".Таблица состоит из колонок: 
	Код книги, доступное количество книг по предложению, цена книги, месяц и год проведения предложения (формат дата)
    Первых этих 5 покупок будут по цене 99, скидки покупателя не влияют на цену.} */

-- Решение:

create table BStock(
IDB int, 
bookcount int,
price decimal,
date_of_discount date,
constraint IDB_BStock_fk foreign key(IDB) references books(IDB),
primary key (IDB, date_of_discount) 
);


-- ----------------------------------------------------------------------------------------------------------------------------------------

-- Выполнить все запросы из файла "For_LR2.sql" 

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№3 Создать хранимую процедуру для добавления записей в таблицу "BUMark".
	**{Предусмотреть защиту от появления ошибок при заполнения данных}*/

-- Решение:

create view users_buy_books as select * from Bubuy; 

drop view users_buy_books;

DELIMITER //
create trigger BUMark_insert_validation
before insert 
on BUMark for each row
begin

if new.IDU not in (select IDU from users_buy_books)
then 
	signal sqlstate '45000'
	set message_text = "User doesn't exist or didn't buy any book!";
end if;


if new.IDB not in (select IDB from users_buy_books where IDU = new.IDU)
then
	signal sqlstate '45000'
	set message_text = "Book weren't bought by this user!";
end if;	


if new.page > (select pages from Books where IDB = new.IDB)
then
	signal sqlstate '45000'
	set message_text = "Quantitu of pages in book less than page with ur description!";
end if;	

if new.date_of_describtion < (select datetime from users_buy_books where IDU = new.IDU and IDB = new.IDB)
then
	signal sqlstate '45000' #interrupt
	set message_text = "User didn't wield that book in that time!";
end if;

end//
DELIMITER ;

drop trigger BUMark_insert_validation;

DELIMITER //
create procedure add_BUMark (IDU int, IDB int, page int, description varchar(100), date_of_describtion datetime)
begin

declare exit handler for 1062
begin
	signal sqlstate '45000'
	set message_text = "Trying to add duplicate! Duplicate primary key!";
end;

insert into BUMark values(IDU, IDB, page, description, date_of_describtion);
end//
DELIMITER ;

drop procedure add_BUMark;


-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№4 Добавить в таблицу "BUMark" по 3 записи для пользователей: 'Denis', 'Dunn', 'Dora'.*/

-- Решение:

call add_bumark((select IDU from users where login = 'denis'), (select IDB from books where IDB = 245), 45, 'Silence...', '2023-03-21 12:35:11');
call add_bumark((select IDU from users where login = 'dunn'), (select IDB from books where IDB = 454), 45, 'Exciting heading!', '2022-09-10 23:00:00');
call add_bumark((select IDU from users where login = 'dora'), (select IDB from books where IDB = 340), 89, 'Magnificent!', '2022-11-01 17:45:34');
select * from bumark;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№5 Для каждого покупателя посчитать скидку в зависимости от количества купленных книг:
	+------------------------+------+-------+-------+-------+-------+
	| Количество книг, более |	0   |	3	|	5	|	7	|	10	|
    +------------------------+------+-------+-------+-------+-------+
    | Скидка, %		    	 |	0	|	1	|	2	|	3	|	5	|
	+------------------------+------+-------+-------+-------+-------+
	Решение этой задачи должно быть таким, чтобы потом им можно было воспользоваться для подсчета стоимости при покупке книги.*/

-- Решение:

CREATE TEMPORARY TABLE user_discount (
	IDU int,
	Discount int,
    primary key(IDU)
);

insert into user_discount (select IDU,
case
	when count(IDB) >= 0 and count(IDB) < 3
		then 0
    when count(IDB) >= 3 and count(IDB) < 5
		then 1
    when count(IDB) >= 5 and count(IDB) < 7
		then 2
	when count(IDB) >= 7 and count(IDB) < 10
		then 3
	else 5
end as discount
 from bubuy group by IDU);
 
select * from user_discount;

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Предложить альтернативную идею или идеи для решения задачи №5.}

-- Решение:

DELIMITER //
create function discount_for_user(user int)
returns int
DETERMINISTIC  -- for the same input values the same reulst otherwise not deterministic
begin
	
	declare discount int;
    set discount = 0;
    
    set discount =  (select count(IDB) as bookcount from bubuy where IDU = user);
    
    if discount >=0 and discount < 3
		then set discount = 0;
    elseif discount >=3 and discount < 5
		then set discount = 1;
	elseif discount >=5 and discount < 7
		then set discount = 2;
	elseif discount >=7 and discount < 10
		then set discount = 3;
	else set discount = 5;
    end if;
    
    return discount;
    
end//
DELIMITER ; 

select discount_for_user(1);

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№6 Создать представление, которое будет выводить список 10 самых покупаемых книг за предыдущий месяц 
(при одинаковом значении проданных книг, сортировать по алфавиту) */

-- Решение:
create view prev_month_top_books as
select B.title as book, count(B.IDB) as quantity from bubuy inner join books as B using(IDB) where month(datetime) = month(date_add(now(), interval -1 month)) and year(datetime) = year(now()) group by B.title order by count(B.IDB) desc, B.title asc limit 10;

select * from prev_month_top_books;

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Сделать выборку по условию задачи №6 и добавить к решению нумерацию строк}

-- Решение:
select (row_number() over (order by quantity desc, book asc) ) as number, book, quantity from prev_month_top_books;


set @row_number = 0;
select *, (@row_number:=@row_number + 1) as number from prev_month_top_books;

select (@row_number:=@row_number + 1) as number, book, quantity from prev_month_top_books, (select @row_number:=0) as temp order by quantity desc, book asc; 

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Заполнить таблицу "BStock" на текущий месяц. 10 записей из списка задачи №6, ручной ввод IDB не допускается.}

-- Решение:
DELIMITER //
create procedure bstockInsertBegin()
begin                                                                                           # utc_date for date format YYYY-MM-DD
insert into Bstock (select B.IDB as IDB, round(RAND()*(21-5) + 5) as bookcount, 99.00 as price, utc_date() as date_of_discount from bubuy as A inner join books as B using(IDB) where month(datetime) = month(date_add(now(), interval -1 month)) and year(datetime) = year(now()) group by B.title order by count(B.IDB) desc, B.title asc limit 10);
end//
DELIMITER ; 

call bstockInsertBegin();

#insert into Bstock
(select B.IDB as IDB, round(RAND()*(21-5) + 5) as bookcount, round((B.price - B.price * (RAND()*(0.4-0) + 0))) as price, utc_date() as date_of_discount from bubuy as A inner join books as B using(IDB) where month(datetime) = month(date_add(now(), interval -1 month)) and year(datetime) = year(now()) group by B.title order by count(B.IDB) desc, B.title asc limit 10);
select * from bstock;

#update after 5 sales
update Bstock as st set price = (select round((B.price - B.price * (RAND()*(0.4-0) + 0))) from books as B where B.IDB = st.IDB);


-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№7 Написать хранимую процедуру. Для книг (если название и автор совпадает) вывести количество изданий, минимальную и максимальную стоимость. 
Отобразить только те записи, у которых есть несколько упоминаний.*/

-- Решение:

DELIMITER //
create procedure many_type_of_one_book()
begin
select distinct B.title, B.price as maxprice, Bs.price as minprice from books as B inner join bubuy using(IDB) inner join bstock as Bs using(IDB);
end//
DELIMITER ;


call many_type_of_one_book();

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№8 Создать триггер который будет копировать исходную строку в "новую архивную таблицу" при редактирование данных в таблице "USERS".	*/

-- Решение:
select * from bstock;
create table archiveusers(
id int auto_increment primary key,
IDU int,
mail varchar(65),
login varchar(45),
pass varchar(45),
constraint IDU_archive_fk foreign key(IDU) references users(IDU)
);

DELIMITER //
create trigger user_update
before update
on users for each row
begin
insert into archiveusers(IDU, mail, login, pass) values (old.IDU, old.mail, old.login, old.pass);
end//
DELIMITER ;

update users set pass = 'new pass' where IDU in (2,3);
select * from archiveusers;

#drop trigger user_update;
-- ----------------------------------------------------------------------------------------------------------------------------------------
-- **{Написать триггер который будет поддерживать таблицу "BStock" в актуальном состоянии}  */

set @counter = (select count(IDB) from bubuy where IDB in (select IDB from bstock));
select @counter;


-- Решение:
DELIMITER //
create trigger bstock_relevant
before insert
on bubuy for each row
begin

	update bstock set bookcount = bookcount - 1 where IDB = new.IDB;

	if( date_sub(now(), interval 1 month) = (select distinct date(date_of_discount) from bstock) )
    then
    delete from bstock;
    call bstockInsertBegin();
    set @counter = (select count(IDB) from bubuy where IDB in (select IDB from bstock));
	end if;
    
	if((select count(IDB) from bubuy where IDB in (select IDB from bstock)) >= @counter+5)
    then update Bstock as st set price = (select B.price from books as B where B.IDB = st.IDB);
    end if;
    
    
end//
DELIMITER ;


#insert into bubuy value(110, 732, now());

-- ----------------------------------------------------------------------------------------------------------------------------------------
/* №9 Написать хранимую процедуру. Какая книга или книги, самая популярная как первая купленная.*/

-- Решение:

DELIMITER //
create procedure popular_and_first_book ()
begin
select B.title from (select IDB, count(IDB) from bubuy where IDB in (select IDB from bubuy where date(datetime) = (select min(date(datetime)) from bubuy ))  group by IDB) as A inner join books as B using(IDB);
end//
DELIMITER ;

call popular_and_first_book ();

#the same
#select A.IDB, A.count, B.title from (select IDB, count(IDB) as count from bubuy where IDB in (select IDB from bubuy where date(datetime) = (select min(date(datetime)) from bubuy ))  group by IDB) as A inner join books as B using(IDB);

#select IDB, count(IDB) from bubuy where IDB in (select IDB from bubuy where date(datetime) = (select min(date(datetime)) from bubuy )) group by IDB;
#select * from bubuy where IDB = 180;

-- ----------------------------------------------------------------------------------------------------------------------------------------
/*	№10 Вывести пользователей которые не проявили никакой активности (не просматривали книги, ничего не покупали)*/

-- Решение:
select IDU, login from users where IDU not in ( SELECT distinct A.IDU from (select distinct IDU from bubuy union select distinct IDU from BUView) as A );

-- ----------------------------------------------------------------------------------------------------------------------------------------

