-- 1. Выполнить запросы:
drop database if exists DB1;

Create database DB1;

Use DB1;

CREATE TABLE DB1.Basic (
    SongTitle VARCHAR(35),
    Quality ENUM('H', 'L', 'M'),
    Duration INT,
    DateRecord DATE,
    AlbumTitle varchar(35), 
    price decimal (5,2),
    ArtistName varchar(35),
    email varchar(35)
    );
    
insert into Basic (SongTitle, Quality, Duration, DateRecord, AlbumTitle, price, ArtistName, email) values 
('Sing Me To Sleep', 'H', 176, '2018-08-29',null, null, 'Alan Walke', 'AlanWalker@mail.com'),
('The Greatest', 'L', 88, '2019-10-24', 'The Greatest', 2.38, 'Sia', null),
('Cheap Thrills', 'M', 115, '2016-07-16', 'The Greatest', 2.38, 'Sia', null),
('Ocean Drive', 'M', 101,	'2015-12-04', null, null, 'Duke Dumont', null),
('No Money', 'M',	126, '2018-05-11', 'In The Lonely Hour', 3.63, null, null),
('Thinking About It', 'L', 170, '2016-01-14', 'Evolution', 1.88, 'Nathan Goshen', null),
('Perfect Strangers', 'L', 189, '2018-09-06', 'Runway', 2.75, 'Jonas Blue', null),
('Perfect Strangers', 'L', 189, '2018-09-06', 'Runway', 2.75, 'Jp Cooper', null),
('Thinking About It', 'M', 179, '2017-10-25','In The Lonely Hour',3.25, 'Alan Walke', 'AlanWalker@mail.com'),
('Thinking About It', 'M', 179, '2017-10-25','In The Lonely Hour',3.25, 'Jp Cooper', null),
('My Way', 'H', 163, '2018-07-26','My Way', 1.63, 'Frank Sinatra', null),	
('My Way', 'H', 157,	'1985-01-11','The Christmas', 3.63, 'Frank Sinatra', null),
('Let It Snow!', 'M', 158, '1984-03-05','World On A String', 3.38, 'Frank Sinatra', null);

-- 2. Нормальзвать базу данных. Создать новые таблицы и заполнить их с помощью запросов из таблицы Basic
-- решение 

create table artist(
id int auto_increment primary key,
name varchar(25),
email varchar(35)
);


create table album(
id int auto_increment primary key,
AlbumTitle varchar(35), 
price decimal (5,2)
);


create table song(
id int auto_increment primary key,
songtitle varchar(40),
Quality ENUM('H', 'L', 'M'),
Duration INT,
DateRecord DATE
);

create table artist_song(
id int auto_increment primary key,
artist_id int,
song_id int,
constraint artist_fk_artsong foreign key(artist_id) references artist(id) on update cascade on delete cascade,
constraint song_fk_artsong foreign key(song_id) references song(id) on update cascade on delete cascade
);


create table album_song(
id int auto_increment primary key,
album_id int,
song_id int,
constraint album_albumsong_fk foreign key(album_id) references album(id) on update cascade on delete cascade,
constraint song_albumsong_fk foreign key(song_id) references song(id) on update cascade on delete cascade
);


# full artist table
INSERT INTO artist(name, email) select distinct ArtistName, email from Basic where artistname is not null;


#full album table
insert into album(AlbumTitle, price) select distinct B.AlbumTitle, B.price from Basic as B where B.albumtitle is not null;

#full song table
insert into song(songtitle, quality, duration, daterecord) 
select distinct B.songtitle, B.quality, B.duration, B.daterecord from Basic as B;


#result table for artist + song implementation of ManyToMany relationships
insert into artist_song(song_id ,artist_id) 
select S.id , A.id from Basic as B inner join song as S using(songtitle, quality, daterecord, duration) inner join artist as A on A.name = B.artistname;
 

#result table for album + song implementation of ManyToMany relationship
insert into album_song(album_id, song_id) select distinct Al.id, S.id from Basic as B
 inner join album as Al using(albumtitle, price) inner join song as S using (songtitle, quality, daterecord, duration);


select * from artist;
select * from album;
select * from song;  
select * from album_song; 
select * from artist_song;

-- 3. Создать запрос для	добавления нового SongTitle «Can't Stop The Feeling» исполнителя Jonas Blue продолжительностью 253 секунды, аудио запасись сделана 5 августа 2016 в среднем качестве.
-- решение 
INSERT INTO song(songtitle, duration, daterecord, quality) value("Can't Stop The Feeling", 253, '2016-08-05', 'M');
INSERT into artist_song(song_id, artist_id) value((select S.id from song as S where S.songtitle in("Can't Stop The Feeling")), (select A.id from artist as A where A.name in("Jonas Blue") ));

-- 4. Создать запрос для	Переименовать аудио запасись «Thinking About It - Nathan Goshen» в «Let It Go»
-- решение 
UPDATE song
set songtitle = 'Let It Go' where songtitle in ('Thinking About It') and id in(select song_id from artist_song where artist_id in((select A.id from artist as A where A.name in("Nathan Goshen"))));

select * from song;

-- 5. Создать запрос для Удалить колонку «e-mail», создать колонку «Сайт» задав по умолчанию значение «нет»
-- решение 
alter table artist drop column email, add column site varchar(30) default 'none';

select * from artist;

-- 6. Создать запрос для	Вывести все аудио запасиси и если есть информация, то и исполнителя и альбом
-- решение 

select S.songtitle, A.name, Al.albumtitle from artist_song as artsong left join artist as A on artsong.artist_id = A.id right join song as S on S.id = artsong.song_id left join album_song as albsong on S.id = albsong.song_id left join album as Al on Al.id = albsong.album_id;


-- 7. Создать запрос для	Вывести все аудио запасиси, у которых в названии альбома есть «way» 
-- решение 

select S.songtitle, A.albumtitle as '..way..' from album_song as albs inner join song as S on S.id = albs.song_id inner join album as A on A.id = albs.album_id and A.albumtitle regexp('way');

-- 8. Создать запрос для	Вывести название, стоимость альбома и его исполнителя при условии, что он будет самым дорогим для каждого исполнителя.
-- решение 

--
select distinct Al.albumtitle, Al.price, p.name from album_song as albs inner join artist_song as arts using (song_id) inner join album as Al on Al.id = albs.album_id  inner join (select A.name as name, max(Al.price) as price from album_song as albs inner join artist_song as arts using(song_id) inner join artist as A on A.id = arts.artist_id inner join album as Al on Al.id = albs.album_id group by A.name) as p on Al.price = p.price; 
--

# additional select in join provide us with a result
select A.name, max(Al.price) from album_song as albs inner join artist_song as arts using(song_id) inner join artist as A on A.id = arts.artist_id inner join album as Al on Al.id = albs.album_id group by A.name;
select Al.albumtitle, Al.price from album_song as albs inner join artist_song as arts using(song_id) inner join artist as A on A.id = arts.artist_id inner join album as Al on Al.id = albs.album_id group by Al.albumtitle; 

#inner join album as ala on Ala.id = Al.id and Al.price = max(ala.price);

-- 9. Создать запрос для	Удалить запись «Can't Stop The Feeling» исполнителя Jonas Blue.
-- решение 

delete from artist_song where song_id in ((select id from song where songtitle = "Can't Stop The Feeling")) and artist_id in ((select id from artist where name = 'Jonas Blue'));
delete from song where songtitle = "Can't Stop The Feeling";

select * from song;
select * from artist_song;


-- 10** построить схему БД в workbench

