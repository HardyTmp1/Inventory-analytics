
/*
Question:

Which products contribute the most to total inventory value?

💡 Business:

identify top 20% products holding most capital
prioritize monitoring / optimization

*/

with tied_products as (
    select 
        p.product_name product, 
        sum(i.on_hand_quantity) as total_quantity,
        round(sum(i.unit_cost * i.on_hand_quantity),2) as actual_value,
        rank () over (order by sum(i.unit_cost * i.on_hand_quantity) DESC) as ranking
    from 
        fact_inventory i 
    left join product_dim p on i.product_id = p.product_id 
    group by 
        p.product_name
),
bucketing as ( 
    select 
        tp.product, 
        tp.total_quantity quantity, 
        tp.actual_value, 
        ntile(5) over (
                order by tp.actual_value DESC) as bucket, 
        tp.ranking
    from 
        tied_products tp 
)
select 
    b.product, 
    b.quantity, 
    b.actual_value, 
    b.ranking, 
    b.bucket
from 
    bucketing b
where 
    bucket = 1 and product is not NULL 
order by 
    b.actual_value DESC


/*
This query identifies the top 20% of products contributing the most to total inventory value.

It calculates total quantity and inventory value per product, ranks them by value,
and segments products into five buckets using NTILE. The top bucket (bucket = 1)
represents the highest-value products holding the largest share of inventory capital.

This helps prioritize monitoring and optimization efforts on the most financially
significant products.
*/