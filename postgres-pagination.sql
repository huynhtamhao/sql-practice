-- Tại sao không sử dụng COUNT(*) OVER () cho phan trang
-- insert 10tr record
create table milliontable (
    id numeric PRIMARY KEY,
    name varchar(20),
    age numeric
 );

INSERT INTO milliontable (id, name, age)
select
	*,
   substr(md5(random()::text), 1, 10),
       (random() * 70 + 10)::integer
FROM generate_series(1, 10000000);

-- slow : 2 nguyen nhan
-- thứ 1 sẽ sai nếu query ở offset ko tồn tại. Chẳng hạn hiện tại đang ở page kế cuối, tuy nhiên page cuối bị xóa lúc này query ko có data
-- thứ 2 càng nhiều record chạy càng chậm
explain analyse
 SELECT 
	id
	, name
       , COUNT(*) OVER () as totalCount
FROM milliontable
order by ID
OFFSET 9999990
LIMIT 10;

-- Tối ưu với sl record nhiều. Phải xử lý tính toán ở pageable ở Java
explain analyse
SELECT COUNT(*) 
FROM milliontable
-- where name like 'a%'
;

explain analyse  
	SELECT 
		id
		, name
	FROM milliontable
	-- where name like 'a%'
	order by ID
OFFSET 1
LIMIT 10;


-- Lay final page Very Slow
explain analyse  
WITH testT AS (
	SELECT 
		id
		, name
	       , COUNT(*) OVER () as totalCount
	       , row_number() OVER (order by ID) AS rowNum
	FROM milliontable
)
SELECT *
FROM testT
WHERE rowNum > (totalCount - 1)/10 * 10
order by ID;


----------- SQL name generate

create table million_table (
    id numeric PRIMARY KEY,
    first_name varchar(40),
    middle_name varchar(40),
    last_name varchar(40),
    age numeric
 );

select * from million_table;

INSERT INTO million_table (id, first_name, middle_name, last_name, age)
SELECT
    s.*,
    arrays.firstnames[s.a % ARRAY_LENGTH(arrays.firstnames,1) + 1] as first_name,
    substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ' from s.a%26+1 for 1) as middle_name,
    arrays.lastnames[s.a % ARRAY_LENGTH(arrays.lastnames,1) + 1] as last_name,
    (random() * 70 + 10)::integer as age
FROM generate_series(1, 10000000) AS s(a)
CROSS JOIN(
    SELECT ARRAY[
    'Adam','Bill','Bob','Calvin','Donald','Dwight','Frank','Fred','George','Howard',
    'James','John','Jacob','Jack','Martin','Matthew','Max','Michael',
    'Paul','Peter','Phil','Roland','Ronald','Samuel','Steve','Theo','Warren','William',
    'Abigail','Alice','Allison','Amanda','Anne','Barbara','Betty','Carol','Cleo','Donna',
    'Jane','Jennifer','Julie','Martha','Mary','Melissa','Patty','Sarah','Simone','Susan'
    ] AS firstnames,
    ARRAY[
        'Matthews','Smith','Jones','Davis','Jacobson','Williams','Donaldson','Maxwell','Peterson','Stevens',
        'Franklin','Washington','Jefferson','Adams','Jackson','Johnson','Lincoln','Grant','Fillmore','Harding','Taft',
        'Truman','Nixon','Ford','Carter','Reagan','Bush','Clinton','Hancock'
    ] AS lastnames
) AS arrays;

SELECT
    arrays.firstnames[s.a % ARRAY_LENGTH(arrays.firstnames,1) + 1] AS firstname,
    substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ' from s.a%26+1 for 1) AS middlename,
    arrays.lastnames[s.a % ARRAY_LENGTH(arrays.lastnames,1) + 1] AS lastname
FROM     generate_series(1,300) AS s(a) -- number of names to generate
CROSS JOIN(
    SELECT ARRAY[
    'Adam','Bill','Bob','Calvin','Donald','Dwight','Frank','Fred','George','Howard',
    'James','John','Jacob','Jack','Martin','Matthew','Max','Michael',
    'Paul','Peter','Phil','Roland','Ronald','Samuel','Steve','Theo','Warren','William',
    'Abigail','Alice','Allison','Amanda','Anne','Barbara','Betty','Carol','Cleo','Donna',
    'Jane','Jennifer','Julie','Martha','Mary','Melissa','Patty','Sarah','Simone','Susan'
    ] AS firstnames,
    ARRAY[
        'Matthews','Smith','Jones','Davis','Jacobson','Williams','Donaldson','Maxwell','Peterson','Stevens',
        'Franklin','Washington','Jefferson','Adams','Jackson','Johnson','Lincoln','Grant','Fillmore','Harding','Taft',
        'Truman','Nixon','Ford','Carter','Reagan','Bush','Clinton','Hancock'
    ] AS lastnames
) AS arrays

---------
create table result_of_exam (
    id serial PRIMARY KEY,
    student_id varchar(8),
    subject_id varchar(8),
    score int2
 );
insert into result_of_exam (student_id, subject_id, score) values ('STD1', 'Math', 8);
insert into result_of_exam (student_id, subject_id, score) values ('STD1', 'Science', 9);
insert into result_of_exam (student_id, subject_id, score) values ('STD2', 'Math', 4);
insert into result_of_exam (student_id, subject_id, score) values ('STD2', 'Science', 7);
insert into result_of_exam (student_id, subject_id, score) values ('STD3', 'Math', 8);
insert into result_of_exam (student_id, subject_id, score) values ('STD3', 'Science', 0);
insert into result_of_exam (student_id, subject_id, score) values ('STD4', 'Math', 10);
