

select * from fact_inventory limit 10


select * from geography_dim limit 10

select * from fact_inventory limit 10

select * from date_dim limit 10

select * from store_dim limit 10

select * from product_dim limit 10

select * from product_category_dim limit 10

alter table store_dim rename column "store_key" to store_id
alter table date_dim rename column "date_key" to date_id 
alter table store_dim rename column "geography_key" to geography_id

ALTER TABLE fact_inventory
ADD CONSTRAINT fk_fact_inventory_date
FOREIGN KEY (date_id)
REFERENCES date_dim(date_id);

ALTER TABLE fact_inventory 
ADD CONSTRAINT fk_fact_inventory_



select * from fact_inventory where inventory_id = 4

ALTER TABLE fact_inventory
RENAME CONSTRAINT fact_inventory_pkey TO fk_fact_inventory_date_id

ALTER TABLE fact_inventory
RENAME CONSTRAINT fk_fact_inventory_date TO date_id

ALTER TABLE date_dim
RENAME CONSTRAINT date_dim_pkey TO date_id

select * from date_dim limit 10

alter table geography_dim 
rename constraint geography_dim_pkey to geography_id


SELECT fact_inventory
FROM information_schema.tables
WHERE table_schema = 'public';

select * from fact_inventory limit 10



ALTER TABLE fact_inventory
ADD CONSTRAINT store_id
FOREIGN KEY (store_id)
REFERENCES store_dim(store_id);

ALTER TABLE fact_inventory
ADD CONSTRAINT currency_id
FOREIGN KEY (currency_id)
REFERENCES currency_dim(currency_id);

SELECT DISTINCT f.product_id
FROM fact_inventory f
LEFT JOIN product_dim p
    ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT *
FROM fact_inventory f
WHERE NOT EXISTS (
    SELECT 1
    FROM product_dim p
    WHERE p.product_id = f.product_id
);


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('fact_inventory', 'product_dim')
  AND column_name = 'product_id';


CREATE TABLE currency_dim (
    currency_id INT PRIMARY KEY,
    currency_name	VARCHAR(512),
    currency_description VARCHAR(512)
);


copy currency_dim
FROM 'D:\End_to_end_project\currency_dim.csv'
DELIMITER ','
CSV HEADER;

alter table fact_inventory 
add constraint product_id 
foreign key (product_id)
references product_dim (product_id);


SELECT DISTINCT f.product_id
FROM fact_inventory f
LEFT JOIN product_dim p
    ON f.product_id = p.product_id
WHERE p.product_id IS NULL
ORDER BY f.product_id;

select * from fact_inventory limit 10
select * from date_dim limit 10
select * from store_dim limit 10
select * from product_dim limit 10
select * from product_category_dim limit 10
select * from geography_dim limit 10

CREATE TABLE "geography_dim" (
    "geography_id"	INT PRIMARY KEY,
    "geography_type"	VARCHAR(512),
    "continent_name"	VARCHAR(512),
    "city_name"	VARCHAR(512),
    "state_province_name"	VARCHAR(512),
    "region_country_name"	VARCHAR(512)
);


copy geography_dim
FROM 'D:\End_to_end_project\DimGeography.csv'
DELIMITER ','
CSV HEADER;

alter table store_dim
add constraint geography_id 
foreign key (geography_id)
references geography_dim (geography_id);

alter table geography_dim 
rename constraint geography_dim_pkey to geography_id 



select count(*) 
from (
  select distinct f.product_id
  from fact_inventory f
  left join product_dim p
    on f.product_id = p.product_id
  where p.product_id is null
) t;


select distinct
    f.product_id 
from 
    fact_inventory f 
left join product_dim as pd on f.product_id = pd.product_id 
where 
    pd.product_id is NULL

select distinct * from fact_inventory where product_id = 2234

select count(*)
from fact_inventory
where product_id in (
  select distinct f.product_id
  from fact_inventory f
  left join product_dim p
    on f.product_id = p.product_id
  where p.product_id is null
);


select 
	count(*) as rows_to_delete,
	round(
		100.0 * count(*) / (select count(*) from fact_inventory),
		2
	) as pct_of_fact
from fact_inventory
where product_id in (
	select distinct f.product_id
	from fact_inventory f
	left join product_dim p
		on f.product_id = p.product_id
	where p.product_id is null
);

select 
	f.product_id,
	count(*) as affected_rows
from fact_inventory f
left join product_dim p
	on f.product_id = p.product_id
where p.product_id is null
group by f.product_id
order by affected_rows desc;


create table product_dim_backup as
select *
from product_dim;

CREATE TABLE "product_dim" (
    "product_id"	INT PRIMARY KEY,
    "product_name"	VARCHAR(512),
    "product_description"	VARCHAR(512),
    "product_category_id"    INT,
    "manufacturer"	VARCHAR(512),
    "brand_name"	VARCHAR(512),
    "class_id"	INT,
    "class_name"	VARCHAR(512),
    "style_id"	INT,
    "style_name"	VARCHAR(512),
    "color_id"	INT,
    "color_name"	VARCHAR(512),
    "weight"	VARCHAR(512),
    "weight_unit_measure_id"	VARCHAR(512),
    "unit_of_measure_id"	INT,
    "unit_of_measure_name"	VARCHAR(512),
    "stock_type_id"	INT,
    "stock_type_name"	VARCHAR(512),
    "unit_cost"	NUMERIC,
    "unit_price"	NUMERIC,
    "available_for_sale_date"	VARCHAR(512),
    "status"	VARCHAR(512)
);

insert into product_dim (product_id)
select distinct f.product_id
from fact_inventory f
left join product_dim p
	on f.product_id = p.product_id
where p.product_id is null;


select distinct f.product_id
from fact_inventory f
left join product_dim p
	on f.product_id = p.product_id
where p.product_id is null
order by f.product_id;


alter table fact_inventory
add constraint product_id
foreign key (product_id)
references product_dim(product_id);


alter table product_dim 
rename constraint product_dim_pkey to product_id 


alter table product_dim
add constraint product_category_id
foreign key (product_category_id)
references product_category_dim(product_category_id);

select * from product_category_dim 

select distinct product_category_id as ID 
from product_dim 
order by ID DESC

select * from product_dim

select 
	p.product_category_id,
	count(*) as affected_rows
from product_dim p
left join product_category_dim p2
	on p.product_category_id = p2.product_category_id
where p2.product_category_id is null
group by p.product_category_id
order by affected_rows desc;

insert into product_category_dim (product_category_id)
select distinct p.product_category_id
from product_dim p
left join product_category_dim p2
	on p.product_category_id = p2.product_category_id
where p.product_category_id is not null
  and p2.product_category_id is null;

select
	p.product_category_id,
	count(*) as affected_rows
from product_dim p
left join product_category_dim p2
	on p.product_category_id = p2.product_category_id
where p.product_category_id is not null
  and p2.product_category_id is null
group by p.product_category_id
order by affected_rows desc;

alter table product_dim
add constraint product_category_id
foreign key (product_category_id)
references product_category_dim(product_category_id);

select product_category_id 
from product_category_dim as pcd
where product_category_id is NULL


select * 
from fact_inventory 
where inventory_id = 4504



CREATE INDEX fact_product_index ON fact_inventory(product_id);
CREATE INDEX fact_store_index ON fact_inventory(store_id);
CREATE INDEX fact_date_index ON fact_inventory(date_id);


SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'fact_inventory';