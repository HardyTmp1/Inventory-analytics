
/*Question:

Which products contribute the most to overstock value?

💡 Business:

not all overstock is equal
find where money is stuck

*/

select 
    product,
    actual_value, 
    pct_overstock, 
    actual_value_overstock,
    case 
        when actual_value_overstock > avg(actual_value_overstock) over () and 
            pct_slow_movers > avg(pct_slow_movers) over () then 'Discount'
        when actual_value_overstock > avg(actual_value_overstock) over () then 'Reduce purchasing'
        else 'Monitor'
    end as Solution_layer
from (
    select 
        p.product_name product, 
        round(sum(i.unit_cost * i.on_hand_quantity),2) actual_value,
        round(100 * sum(case when i.on_hand_quantity > i.safety_stock_quantity then 1 else 0 end)
            / count(*),2) as pct_overstock, 
        sum(case when i.on_hand_quantity > i.safety_stock_quantity then i.unit_cost * i.on_hand_quantity
            else 0 end) as actual_value_overstock,
        round(100 * sum(case when i.days_in_stock > 90 then 1 else 0 end) / count(*),2) as pct_slow_movers,
        round(100 * sum(case when i.on_hand_quantity > i.safety_stock_quantity then 
            i.unit_cost * i.on_hand_quantity else 0 end) / sum(i.unit_cost * i.on_hand_quantity),2) pct_actual_value
    from 
        fact_inventory i 
    left join product_dim p ON i.product_id = p.product_id 
    group by 
        p.product_name
    order by 
        actual_value_overstock DESC
) metrics


/*
Calculated overstock value per product to identify 
where the largest amount of inventory capital is tied up.

Products with above-average overstock value and high slow-mover rates were marked
for discounting, while products with high overstock value only were marked for
reduced purchasing. Remaining products were kept under monitoring.
*/