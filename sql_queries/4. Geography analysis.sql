

/*Question:
> Which countries/regions have the highest inventory levels?

Join:
* store_dim → geography_dim

💡 Business:
* regional demand patterns
* supply chain decisions

*/

with store_performance as (
    select 
        s.store_name store, 
        g.region_country_name country, 
        round(100 * sum(case when on_hand_quantity < safety_stock_quantity and 
                        days_in_stock < 90 then 1 else 0 end)/ count(*),1) as high_demand,
        count(i.inventory_id) as quantity, 
        round(100 * sum(case when on_hand_quantity > safety_stock_quantity then 1 else 0 end)
                /count(*),2) pct_overstock,
        round(100 * sum(case when on_hand_quantity < safety_stock_quantity then 1 else 0 end)
                /count(*),2) pct_understock, 
        round(100 * sum(case when days_in_stock > 90 then 1 else 0 end)
                /count(*),2) pct_slow_movers,
        sum(i.unit_cost * i.on_hand_quantity) as total_value 
    from 
        fact_inventory i
    left join store_dim s ON i.store_id = s.store_id 
    left join geography_dim g ON s.geography_id = g.geography_id 
    group by 
        s.store_name,
        g.region_country_name 
    order by 
        total_value desc
)
select 
    sp.store, 
    sp.country, 
    sp.total_value, 
    case 
        when sp.pct_overstock > 83 then 'Stop supply' 
        when sp.pct_understock > 13 then 'Increase supply'
        when sp.pct_slow_movers > 7 then 'Promote'
        else 'Balanced'
    end as Supply_chain_decision
from 
    store_performance sp


/*
Calculated inventory value and key performance indicators 
(overstock, understock, and slow movers) per store and region, 
then applied data-driven thresholds to generate actionable 
supply chain decisions such as increasing supply, reducing supply, or promoting inventory.
*/