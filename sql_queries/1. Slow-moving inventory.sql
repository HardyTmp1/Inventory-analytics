
/*Question:
Which products are sitting too long in stock?

Question:
Which products have the highest days_in_stock or aging?

Why it matters:

dead stock = lost money
storage cost
cash flow blocked
*/

1. 
select 
    product_name, 
    days_in_stock 
from 
    fact_inventory as inventory 
join product_dim as product 
    on inventory.product_id = product.product_id 
order by 
    days_in_stock DESC
limit 10

2.
select 
    product_name, 
    days_in_stock 
from 
    fact_inventory as inventory 
join product_dim as product 
    on inventory.product_id = product.product_id 
where 
    days_in_stock > (
            select avg(days_in_stock) 
            from fact_inventory
    ) and product_name is not NULL
order by 
    days_in_stock desc
limit 100




/*
1. This query highlights the products that have remained in inventory 
for the longest period. These items represent the most critical 
slow-moving stock and may indicate a risk of dead inventory, 
higher storage costs, and capital being tied up for too long.

2. This query identifies a broader group of products performing worse 
than the inventory average. Instead of focusing only on the 
top 10 extreme cases, this approach helps detect all products
that are moving more slowly than normal and may require further 
investigation. 

Note: This query may take longer to execute due to the use of aggregation 
   across the entire dataset.
*/













where 
    days_in_stock > (
            select avg(days_in_stock) avg_days_in_stock
            from fact_inventory 
    ) and product_name is not NULL 

