select 
  date_trunc('day', order_datetime) as day,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by day) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by day) -1 as sales_growth,
  lag(sum(sales) / count(*)) over (order by day) as aov_last,
  1.0 * aov / aov_last -1 as aov_growth,
  1 as test
from orders
group by 1
order by 1 desc
limit 365