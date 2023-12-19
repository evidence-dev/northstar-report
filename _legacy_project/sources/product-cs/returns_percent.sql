select 
  returns_abs.day,
  returns,
  orders,
  1.0 * returns / orders as returns_percent,
  lag( returns_percent) over (order by returns_abs.day) as returns_percent_last,
  returns_percent - returns_percent_last as returns_percent_delta
from ${returns_abs} returns_abs
left join ${orders} orders on orders.day = returns_abs.day
order by 1 desc
limit 90