select 
  STRPTIME(SUBSTR(order_datetime, 1, 23), '%a %b %d %Y %T') AS order_datetime_parsed,
  date_trunc('day', order_datetime_parsed) as day,
  avg(sales) as average_price,
  avg(sales) / lag(avg(sales)) over (order by day) -1 as average_price_growth
from orders
group by 1 
order by 1 desc
limit 90