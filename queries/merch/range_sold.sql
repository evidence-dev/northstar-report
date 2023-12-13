select 
  STRPTIME(SUBSTR(order_datetime, 1, 23), '%a %b %d %Y %T') AS order_datetime_parsed,
  date_trunc('day', order_datetime_parsed) as day,
  count(distinct item) as range_sold,
  1.0 * count(distinct item) / lag(count(distinct item)) over (order by day) -1 as range_sold_growth
from orders
group by 1
order by 1 desc
limit 90