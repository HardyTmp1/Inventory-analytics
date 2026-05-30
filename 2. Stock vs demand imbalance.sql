
/* Question:
Are we overstocking or understocking?

### Question:
Compare on_hand_quantity vs on_order_quantity vs safety_stock_quantity
*/

select 
    p.product_name,
    f.on_hand_quantity, 
    f.on_order_quantity,
    f.safety_stock_quantity, 
    (f.on_hand_quantity + f.on_order_quantity) total_available_soon, 
    case 
        when on_hand_quantity < safety_stock_quantity and 
            (on_hand_quantity + on_order_quantity) < safety_stock_quantity 
            then 'critical understock'
        when on_hand_quantity < safety_stock_quantity and 
            (on_hand_quantity + on_order_quantity)  >= safety_stock_quantity 
            then 'understock but covered by incoming orders'
        when on_hand_quantity > safety_stock_quantity 
            then 'overstock'
        else 'balanced'
    end as status_inventory
from 
    fact_inventory f
left join product_dim as p 
    on f.product_id = p.product_id 
where 
    p.product_name is not NULL 
limit 100



/*
This query evaluates inventory health by comparing current stock on hand,
incoming stock on order, and the safety stock threshold.

It classifies products into four groups:
- critical understock: current and incoming stock are both insufficient
- understock but covered by incoming orders: current stock is low, but replenishment is enough
- overstock: current stock exceeds the safety stock level
- balanced: stock is maintained at an acceptable level

This analysis helps identify stockout risk, replenishment coverage,
and excess inventory positions.
*/
