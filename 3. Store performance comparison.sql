

/*Question:
Which stores hold the most inventory value?

Use:

- store_dim
- fact_inventory.unit_cost * on_hand_quantity

💡 Business:
- identify inefficient stores
*/


with store_diagnosis as (
    select 
        s.store_name, 
        sum(f.unit_cost * f.on_hand_quantity) actual_value,
        round(avg(f.on_hand_quantity / f.safety_stock_quantity),2) avg_ratio,
        round(100 * sum(case when on_hand_quantity < safety_stock_quantity then 1 else 0 end)
                / count(*),2) pct_understock,
        round(100 * sum(case when on_hand_quantity > safety_stock_quantity then 1 else 0 end)
                / count(*),2) pct_overstock,
        round(100 * sum(case when on_hand_quantity < safety_stock_quantity 
            then unit_cost * on_hand_quantity else 0 end)
                / sum(unit_cost * on_hand_quantity),2) pct_understock_values,
        round(100 * sum(case when on_hand_quantity > safety_stock_quantity 
            then unit_cost * on_hand_quantity else 0 end)
                / sum(unit_cost * on_hand_quantity),2) pct_overstock_values, 
        round(100 * sum(case when days_in_stock > 90 then 1 else 0 end)
                / count (*),2) pct_slow_movers
    from 
        fact_inventory f 
    left join store_dim as s ON f.store_id = s.store_id 
    group by 
        s.store_name
    order by 
        actual_value desc
)
select 
    store_name, 
    actual_value,
    case 
        when (pct_overstock_values > 75 and pct_slow_movers > 8) or (pct_understock > 18) then 'Inefficient'
        when pct_overstock_values < 60 and pct_understock < 10 and pct_slow_movers < 5 then 'Efficient'
    else 'Watchlist'
end as store_status
from 
    store_diagnosis 
order by 
    actual_value DESC


/* 
This analysis evaluates inventory distribution across stores 
by calculating the total inventory value using unit cost 
and on-hand quantity. Beyond identifying which stores hold 
the highest inventory value, the analysis introduces a diagnostic 
layer to assess inventory efficiency.

Key performance indicators were developed to measure stock balance, 
including the percentage of overstocked and unde    rstocked items, 
value concentration in overstock, and the share of slow-moving inventory. 
Based on these metrics, stores were classified into three categories:

Inefficient – stores with high capital tied in slow-moving overstock or 
significant stock shortages
Efficient – stores maintaining balanced inventory with minimal risk indicators
Watchlist – stores that fall between optimal and inefficient performance

The results highlight not only where inventory value is concentrated, 
but also whether that value is being managed effectively, enabling better 
decision-making around stock optimization and operational efficiency.

NOTE: I selected these thresholds based on the average percentage distribution of the data, 
choosing values near the upper ranges
 (e.g., >75% overstock value, >8% slow movers, >18% understock) 
 to isolate only the most extreme and meaningful cases, 
 while lower ranges define stable, low-risk performance.
*/

