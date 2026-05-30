

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
    mpr.available_inventory,
    mpr.pct_fast_movers,
    mpr.pct_understock, 
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



/*
Compared regional demand against available 
inventory to identify possible supply gaps.

Used fast movers and understock products as demand indicators, 
then compared each region against overall average demand and 
inventory levels using window functions.

Regions with high demand but below-average inventory were marked as supply gaps,
while regions with low demand and high inventory were treated as excess allocation areas.
*/

