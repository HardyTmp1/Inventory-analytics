
/*Question:

Which months or periods show the highest fluctuations in inventory value?

💡 Business:

detect unstable periods
improve planning and forecasting

*/

select * from date_dim limit 10


with values as (
    select
        d.calendar_year as years,
        d.calendar_month_label as months,
        d.month_number,
        sum(i.on_hand_quantity) as inventory,
        sum(i.unit_cost * i.on_hand_quantity) as total_value
    from
        date_dim d
    left join fact_inventory i on d.date_id = i.date_id
    where 
        i.inventory_id <> 0
    group by 
        years, 
        months,
        d.month_number
),
flexibility as (
    select  
        years, 
        months,
        month_number,
        inventory, 
        total_value,
        lag(total_value) over (order by years, month_number) as prev_value
    from 
        values
)
select 
    years, 
    months, 
    inventory, 
    total_value,
    prev_value,
    ABS(total_value - prev_value) as absolute_diff,
    ROUND(ABS(total_value - prev_value) / NULLIF(prev_value, 0) * 100, 2) as pct_change
from 
    flexibility
order by 
    pct_change DESC



/*
This query identifies the most unstable periods 
in the supply chain by calculating the monthly 
percentage change in total inventory value. 
By engineering a financial metric ($Cost \times Quantity$)
 and using a LAG window function, the query compares 
 each month’s value to the previous one to detect 
 significant fluctuations. Using absolute values 
 allows the business to see both massive spikes 
 and sudden drops as equally critical planning failures. 
 The final results pinpoint exactly where forecasting 
 went off-track, providing a prioritized list of 
 timeframes that require better procurement 
 management to protect cash flow.
*/