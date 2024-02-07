--Задание_1
-- Создание таблицы "Destination"
CREATE TABLE Destination (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    id_status INT,
    FOREIGN KEY (id_status) REFERENCES Status(id)
);

-- Создание таблицы "Tickets"
CREATE TABLE Tickets (
    id SERIAL PRIMARY KEY,
    id_destination INT,
    lowest_price DECIMAL(10, 2),
    highest_price DECIMAL(10, 2),
    FOREIGN KEY (id_destination) REFERENCES Destination(id)
);

-- Создание таблицы "Status"
CREATE TABLE Status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

-- Заполнение таблицы "Status"
INSERT INTO Status (name) VALUES 
    ('Ожидает подтверждения'),
    ('Подтверждено'),
    ('Отменено');

-- Заполнение таблицы "Destination"
INSERT INTO Destination (name, id_status)
SELECT 
    'Место ' || id AS name,
    (random()*3 + 1)::int -- Генерация случайного статуса (1, 2 или 3)
FROM 
    generate_series(1, 10) id; -- Создание 10 случайных мест назначения

-- Заполнение таблицы "Tickets"
INSERT INTO Tickets (id_destination, lowest_price, highest_price)
VALUES
    (1, 100.00, 150.00),
    (2, 75.00, 120.00),
    (3, 90.00, 140.00),
    (4, 110.00, 160.00),
    (5, 80.00, 130.00);

/*
Уникальные названия маршрутов (destination.name),
для которых существуют билеты (есть запись в tickets). 
Вывести только названия. 
*/
select distinct name from destination
where id in (select distinct id_destination from tickets);

-- Дополните предыдущий запрос: ограничьте маршруты статусом «Без визы».

select distinct name, id from destination
where id in (select distinct id_destination from tickets)
and id_status = (select id from status where name = 'Подтверждено');

/*
Найдите маршруты, максимальная цена которых выше общей средней. 
Общая средняя находится как среднее значение lowest_price и highest_price. 
Вывести названия и высшую цену.
*/

select name, highest_price from tickets t
join destination d
on d.id = t.id_destination
where highest_price > 
(select (avg(lowest_price)+avg(highest_price))/2 from tickets);

--Задание_2

CREATE TABLE "user" (
    id_user SERIAL PRIMARY KEY,
    user_name VARCHAR(50),
    user_surname VARCHAR(50),
    user_weight INT,
    age INT
);

INSERT INTO "user" (id_user, user_name, user_surname, user_weight, age)
VALUES
    (1, 'Anna', 'Ivanova', 56, 8),
    (2, 'Igor', 'Bulik', 75, 45),
    (3, 'Max', 'Nikolsky', 67, 16),
    (4, 'Kate', 'Svet', 66, 30);


CREATE TABLE visits (
    id_visit SERIAL PRIMARY KEY,
    id_user INT,
    hours_spent FLOAT,
    class_name VARCHAR(50),
    date DATE
);

INSERT INTO visits (id_visit, id_user, hours_spent, class_name, date)
VALUES
    (1, 1, 1, 'Zumba', '2023-06-30'),
    (2, 3, 2, 'Swimming pool', '2023-07-04'),
    (3, 5, 1, 'Flex', '2023-07-09'),
    (4, 1, 3, 'Flex', '2023-07-15'),
    (5, 5, 2, 'Step', '2023-07-20'),
    (6, 2, 1.5, 'Football', '2023-07-22');

-- Список уникальных классов. Вывести только названия.
select distinct class_name from visits;

/*
Количество часов, проведенных на занятиях, для каждого пользователя. 
Вывести фамилию, имя и количество часов.
*/
select user_surname, user_name, COALESCE(sum(hours_spent), 0)
from visits v right outer join "user" as u 
on u.id_user = v.id_user
group by user_surname, user_name;

-- Средний возраст пользователей, посещающих класс Flex.
select avg(age) from "user"
where id_user in (select id_user from visits where class_name='Flex');

--Задание_3

CREATE TABLE book (
    id_book SERIAL PRIMARY KEY,
    title VARCHAR(100),
    id_author INT,
    pages INT,
    year_publish DATE
);

INSERT INTO book (id_book, title, id_author, pages, year_publish)
VALUES
    (1, 'The Great Gatsby', 1, 180, '1925-04-10'),
    (2, 'To Kill a Mockingbird', 2, 281, '1960-07-11'),
    (3, '1984', 3, 328, '1949-06-08'),
    (4, 'The Catcher in the Rye', 4, 234, '1999-07-16'),
    (5, 'Pride and Prejudice', 5, 279, '1999-01-28'),
    (6, 'Animal Farm', 3, 112, '1999-08-17'),
    (7, 'Lord of the Flies', 6, 224, '1999-09-17'),
    (8, 'Brave New World', 7, 311, '1932-01-01'),
    (9, 'Crime and Punishment', 8, 671, '1866-11-14'),
    (10, 'The Grapes of Wrath', 9, 464, '1939-04-14');

CREATE TABLE author (
    id_author INTEGER PRIMARY KEY,
    full_name VARCHAR(100),
    century INT
);

INSERT INTO author (id_author, full_name, century)
VALUES
    (1, 'F. Scott Fitzgerald', 20),
    (2, 'Harper Lee', 20),
    (3, 'George Orwell', 20),
    (4, 'J.D. Salinger', 20),
    (5, 'Jane Austen', 19),
    (6, 'William Golding', 20),
    (7, 'Aldous Huxley', 20),
    (8, 'Fyodor Dostoevsky', 19),
    (9, 'John Steinbeck', 20),
    (10, 'Leo Tolstoy', 19);


/*
Уникальные названия всех книг, опубликованных после 1990 года. 
Вывести только названия.
*/
select distinct title from book
where to_char(year_publish, 'YYYY') > '1990'; 

/*
Для каждого автора найти сумму напечатанных страниц. 
Вывести полное имя автора и сумму страниц.
*/

select full_name, sum(pages) from book b
join author au on b.id_author = au.id_author
group by full_name;

/* 
Подсчитать количество книг авторов каждого века. 
Вывести век и количество книг.
*/

select author.century, count(book.id_book) as book_count
from author
join book on author.id_author = book.id_author
group by author.century;