select 
  date_trunc('day', order_datetime) as day,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by day) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by day) -1 as sales_growth,
  sum(sales) / count(*) / lag(sum(sales)) over (order by day) -1 as aov_growth
from orders
where channel_group ilike '%paid%'
or channel_group ilike '%social%'
group by 1
order by 1 desc
limit 90