

/*Question:

Which regions have high demand but low available inventory?

💡 Business:

    detect supply gaps
    improve allocation across regions

*/ 

with metrics_per_region as (
    select 
        g.region_country_name as country,
        round (100 * sum(case when i.days_in_stock < 90 then 1 else 0 end) 
            / count(*),2) as pct_fast_movers,
        round (100 * sum(case when i.on_hand_quantity < i.safety_stock_quantity then 1 else 0 end)
            / count(*),2) as pct_understock,
        round (100 * sum(case when i.days_in_stock < 90 and i.on_hand_quantity < i.safety_stock_quantity 
            then 1 else 0 end) / count(*),2) as high_demand,
        sum (i.on_hand_quantity) as available_inventory
    from 
        fact_inventory i 
    left join store_dim as s on i.store_id = s.store_id 
    left join geography_dim g on s.geography_id = g.geography_id 
    group by 
        country   
)
select 
    mpr.country, 
    mpr.high_demand,
    case when mpr.high_demand > avg(mpr.high_demand) over () and 
        available_inventory < avg(available_inventory) over () then 'supply gap'
        when mpr.high_demand > avg(mpr.high_demand) over () and 
        available_inventory > avg(available_inventory) over () then 'demand covered'
        when mpr.high_demand < avg(mpr.high_demand) over () and 
        available_inventory > avg(available_inventory) over () then 'excess allocation'
        else 'balanced'
    end as demand_status
from 
    metrics_per_region mpr





select 
    round(avg(pct_fast_movers),2) as avg_fast_movers,
    round(avg(pct_understock),2) as avg_understock,
    round(avg(available_inventory),2) as avg_inventory
from 
    metrics_per_country