select 
  date_trunc('day', order_datetime) as day,
  avg(sales) as average_price,
  avg(sales) / lag(avg(sales)) over (order by day) -1 as average_price_growth
from orders
group by 1 
order by 1 desc
limit 90