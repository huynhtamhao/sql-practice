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
