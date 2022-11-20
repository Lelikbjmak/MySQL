-- DROP TABLE IF EXISTS Космос;

CREATE DATABASE IF NOT EXISTS Cosmos;

USE Cosmos;

SET SQL_SAFE_UPDATES = 1; # turn on safe update

DROP TABLE IF EXISTS Stars;

CREATE TABLE IF NOT EXISTS Stars
(
 id int auto_increment primary key ,
 star_name tinytext,
 constellation tinytext,
specter_class varchar(1),
temperature_K int,
weigth_in_sun double,
radius_in_sun double,
distance double,
absolute_star_index double,
visibile_star_index double 
);

INSERT Stars
VALUES (1,'Альдебаран', 'Телец', 'M', 3500, 5, 45, 68, -0.63, 0.85);

SELECT * FROM Stars;

INSERT Stars
VALUES  (2,'Гакрукс', 'Южный крест', 'M', 3400, 3, 113, 88, -0.56, 1.59),
        (3,'Полярная', 'Малая медведица', 'F', 7000, 6, 30, 430, -3.6, 1.97),
        (4,'Беллатрикс', 'Орион', 'B', 22000, 8.4, 6, 240, -2.8, 1.64),
        (5,'Арктур', 'Волопас', 'K', 4300, 1.25, 26, 37,-0.28, -0.05),
        (6,'Альтаир', 'Орел', 'A', 8000, 1.7, 1.7, 360, 2.22, 0.77),
        (7,'Антарес', 'Скорпион', 'K', 4000, 10, 880, 600, -5.28, 0.96),
        (8,'Ригель', 'Орион', 'B', 11000, 18, 75, 864, -7.84, 0.12),
        (9,'Бетельгейзе', 'Орион', 'M', 3100, 20, 900, 650, -5.14, 1.51);
        
SELECT * FROM Stars;

INSERT Stars(star_name, constellation, specter_class, temperature_K, weigth_in_sun, radius_in_sun)
VALUES ('Сириус', 'Большой Пес', 'A', 9900, 2, 1.7);

SELECT * FROM Stars;

UPDATE Stars SET visibile_star_index=1.4 WHERE id=10;

SELECT * FROM Stars;

DELETE FROM Stars
WHERE id=1;

SELECT * FROM Stars;

SET SQL_SAFE_UPDATES = 0;

UPDATE Stars SET absolute_star_index=-1.46,distance=8.6 WHERE star_name='Сириус';

SELECT * FROM Stars;

DELETE FROM Stars
WHERE star_name='Сириус';

SELECT * FROM Stars;

SELECT star_name, temperature_K FROM Stars
ORDER BY star_name;

SELECT star_name, constellation FROM Stars
WHERE constellation IN('Орион'); # or like '...'

SELECT star_name, constellation, specter_class FROM Stars
WHERE constellation like ('Орион') AND specter_class IN('B') ;

SELECT star_name, MAX(distance) FROM Stars;

select star_name from Stars where distance in (select max(distance) from Stars);

SELECT star_name, MIN(distance) FROM Stars;



SELECT specter_class, AVG(temperature_K) AS average_temp  FROM Stars
GROUP BY specter_class;

SELECT specter_class, COUNT(specter_class) AS quantity FROM Stars
GROUP BY specter_class;

SELECT SUM(weigth_in_sun) AS entire_weight From Stars;

SELECT specter_class, MIN(temperature_K) AS lowest_temp FROM Stars
WHERE specter_class='K';



# additional question
select star_name from Stars where temperature_K = (select min(temperature_K) from Stars where specter_class in('K')) and specter_class in ('K');
select star_name from Stars where temperature_K = (select min(temperature_K) from Stars where specter_class in('K') and specter_class in ('K'));





