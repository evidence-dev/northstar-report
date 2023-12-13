select 
  date,
  allocated_spend,
  orders,
  allocated_spend / orders as cpa,
  --day on day change in spend and cpa
  allocated_spend / lag(allocated_spend) over (order by date) -1 as spend_growth,
  cpa / lag(cpa) over (order by date) -1 as cpa_growth
from ${spend}
left join ${paid_orders} on date = day
order by 1 desc
limit 90