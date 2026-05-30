

/*Question:
> How does inventory change over time?

Use:

* date_dim

💡 Examples:

* monthly trends
* seasonal spikes
* fiscal analysis

*/

1. Monthly trends

with monthly_values as (
    select 
        d.calendar_month_label months,
        d.month_number, 
        d.calendar_year,
        sum(i.on_hand_quantity) as items, 
        round(sum(i.on_hand_quantity * i.unit_cost),2) as actual_value
    from 
        fact_inventory i 
    left join date_dim d ON i.date_id = d.date_id
    group by 
        d.calendar_month_label,
        d.month_number,
        d.calendar_year
),
prev_month as (
    select 
        mv.calendar_year as year,
        mv.months, 
        mv.items, 
        mv.actual_value, 
        LAG(mv.actual_value) 
            over (order by mv.calendar_year, mv.month_number) as prev_value
    from 
        monthly_values as mv
)
select 
    pm.months,
    pm.year,
    pm.items, 
    pm.actual_value, 
    pm.prev_value,
    (pm.actual_value - pm.prev_value) as diff
from 
    prev_month pm


/*
This query analyzes inventory changes on a monthly basis across multiple years.

It calculates:
- total inventory quantity per month
- total inventory value per month
- previous month inventory value
- month-over-month difference

The diff column shows whether inventory value increased or decreased compared
to the previous month. Positive values indicate growth, while negative values
indicate a decline.

This helps identify monthly inventory trends, sharp increases or drops, and
periods where inventory value significantly changed over time.
*/


2. Seasonal trends 

select 
    d.europe_season as season,
    d.calendar_year as year,
    sum(i.on_hand_quantity) as items, 
    round(sum(i.on_hand_quantity * i.unit_cost),2) as actual_value
from 
    fact_inventory i 
left join date_dim d ON i.date_id = d.date_id
group by 
    season,
    year

/*
Inventory distribution across different business seasons.

It calculates total inventory quantity and value for each season by year,
allowing comparison between periods such as Holiday, Back to School, 
Spring/Business, and No Season.

The results highlight which seasons consistently hold higher inventory levels,
revealing seasonal demand patterns and periods where inventory is more heavily stocked.
*/



3. Fiscal Analysis

select 
    d.fiscal_quarter_label as quarters,
    d.calendar_year as year,
    sum(i.on_hand_quantity) as items, 
    round(sum(i.on_hand_quantity * i.unit_cost),2) as actual_value
from 
    fact_inventory i 
left join date_dim d ON i.date_id = d.date_id
group by 
    quarters,
    year


/*
Inventory distribution across fiscal quarters.

It calculates total inventory quantity and value for each quarter by year,
allowing comparison between Q1, Q2, Q3, and Q4. Almost same with previous query but, 
with different scale.

The results highlight how inventory levels fluctuate across financial periods,
helping identify which quarters carry higher inventory and reflect key business cycles.
*/