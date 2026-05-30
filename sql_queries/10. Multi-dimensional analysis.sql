

/*Question:

> Which product categories perform worst in specific regions over time?

👉 combine:

* product
* geography
* date

*/


with layer_1 as (
    select 
        s.store_type store_type,
        pc.product_category_name product_category, 
        g.region_country_name country,
        d.calendar_year_label years,
        d.calendar_month_label months, 
        d.month_number month_number,
        sum(case 
                when i.on_hand_quantity > i.safety_stock_quantity 
                    then 1 
                    else 0 
                end) count_overstock, 
        sum(case 
                when i.on_hand_quantity < i.safety_stock_quantity
                    then 1
                    else 0
                end) count_understock,
        count(*) count_inventory,
        sum(case 
                when i.days_in_stock > 90
                    then 1
                    else 0
                end) count_slow_movers,
        sum(i.unit_cost * i.on_hand_quantity) actual_value
    from 
        fact_inventory i 
    left join store_dim s on i.store_id = s.store_id 
    left join product_dim p on i.product_id = p.product_id 
    left join product_category_dim pc on p.product_category_id = pc.product_category_id
    left join date_dim d on i.date_id = d.date_id
    left join geography_dim g on s.geography_id = g.geography_id 
    where 
        pc.product_category_name is not NULL 
    group by 
        s.store_type, 
        pc.product_category_name, 
        g.region_country_name, 
        d.calendar_year_label,
        d.calendar_month_label,
        d.month_number
), 
layer_2 as (
    select 
        store_type, 
        product_category, 
        country, 
        years, 
        months,
        month_number,
        count_overstock,
        count_understock, 
        count_slow_movers,
        actual_value,
        round(100 * count_overstock / count_inventory, 2) as pct_overstock,
        round(100 * count_understock / count_inventory, 2) as pct_understock, 
        round(100 * count_slow_movers / count_inventory, 2) as pct_slow_movers,
        lag(actual_value) over (partition by country,product_category,store_type
                                    order by years, month_number) as prev_month
    from 
        layer_1
),
layer_3 as (
    select 
        *,
        lag(pct_overstock) over (partition by country,product_category,store_type
        order by years, month_number) prev_overstock,
        lag(pct_understock) over (partition by country,product_category,store_type
        order by years, month_number) prev_understock, 
        lag(pct_slow_movers) over (partition by country,product_category,store_type
        order by years, month_number) prev_slow_movers,
        row_number() over (partition by country,years,months order by pct_overstock DESC) ranking,
        case 
        when pct_overstock > avg(pct_overstock) over (partition by country) and 
            pct_slow_movers > avg(pct_slow_movers) over (partition by country)
            then 'WORST'
        when pct_overstock < avg(pct_overstock) over (partition by country) and 
            pct_slow_movers < avg(pct_slow_movers) over (partition by country) and 
            pct_understock < avg(pct_understock) over (partition by country) 
            then 'GOOD'
        else 'WATCHLIST'
    end classification
    from 
        layer_2
)
select     
    store_type, 
    product_category, 
    country, 
    years, 
    months,
    actual_value,
    pct_overstock,
    prev_overstock,
    round(pct_overstock - prev_overstock,2) as change_overstock,
    pct_slow_movers,
    prev_slow_movers,
    round(pct_slow_movers - prev_slow_movers,2) as change_slow_movers,
    classification,
    ranking
from 
    layer_3
where 
    ranking <=5 
order by 
    case 
        when classification = 'WORST' then 1
        when classification = 'WATCHLIST' then 2
        when classification = 'GOOD' then 3 
    end ASC




select * from product_dim limit 10

select * from date_dim limit 10

select * from store_dim limit 10

select * from product_category limit 10

select * from geography_dim limit 10


/*
Inventory Performance Analysis: Identifying Worst-Performing Product Categories by Region

This query analyzes inventory health across product categories, 
store types, and geographic regions to identify the worst performers 
based on overstock rates and slow-moving inventory.

Key metrics tracked:
- Overstock percentage (inventory exceeding safety stock levels)
- Slow mover percentage (items in stock >90 days)
- Month-over-month trend changes

Categories are classified as WORST when both overstock and slow 
mover rates exceed country-specific averages, indicating multiple 
inventory problems. The analysis ranks the top 5 worst performers 
per country per month and tracks performance trends over time.

Output highlights categories requiring immediate attention (WORST), 
those needing monitoring (WATCHLIST), and well-managed inventory (GOOD).
 Results are sorted by severity to prioritize action items.

Business value: Enables targeted inventory optimization, 
identifies regional performance patterns, and flags deteriorating 
trends before they impact cash flow or storage costs.
*/

