select 
  STRPTIME(SUBSTR(order_datetime, 1, 23), '%a %b %d %Y %T') AS order_datetime_parsed,
  date_trunc('day', order_datetime_parsed) as day,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by day) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by day) -1 as sales_growth,
  sum(sales) / count(*) / lag(sum(sales)) over (order by day) -1 as aov_growth
from orders
where channel_group not ilike '%paid%'
and channel_group not ilike '%social%'
group by 1
order by 1 desc
limit 90