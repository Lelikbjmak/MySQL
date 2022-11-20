# var 3
create database if not exists universe;

use universe;

create table if not exists galaxy(
galaxy_name varchar(25) not null,
galaxy_type varchar(20) not null
);

drop table if exists galaxy;

drop database if exists universe;

create database if not exists universe;

use universe;

create table if not exists galaxy(
galaxy_name varchar(25) not null,
galaxy_type varchar(20) not null
);


alter table galaxy add column (id int auto_increment), add constraint galaxy_pk primary key(id);


create table if not exists star(
id int auto_increment,
star_name varchar(25) not null, 
discovered_date date not null,
description varchar(25) not null,
in_galaxy_id int not null,
constraint star_pk primary key(id),
constraint star_galaxy_fk foreign key(in_galaxy_id) references galaxy(id) on update cascade on delete cascade
);

create table if not exists planet(
id int auto_increment primary key,
star_id int, 
planet_name varchar(25),
constraint star_id_fk foreign key(id) references star(id) on update cascade on delete cascade
);

alter table star change column description star_mark varchar(25);
alter table star modify column star_mark int not null;

alter table star drop column discovered_date;

show create table planet;
