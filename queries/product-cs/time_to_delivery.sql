select
  STRPTIME(SUBSTR(delivery_slot_start, 1, 23), '%a %b %d %Y %T') AS delivery_slot_start_parsed,
  STRPTIME(SUBSTR(order_datetime, 1, 23), '%a %b %d %Y %T') AS order_datetime_parsed,
  date_trunc('day', order_datetime_parsed) as day,
  avg(extract(epoch from STRPTIME(SUBSTR(delivery_slot_start, 1, 23), '%a %b %d %Y %T') - order_datetime_parsed) / 60 / 60 / 24) as days_to_delivery_slot,
  lag(days_to_delivery_slot) over (order by day) as days_to_delivery_slot_last,
  days_to_delivery_slot / days_to_delivery_slot_last -1 as days_to_delivery_slot_growth
from deliveries
group by 1
order by 1 desc
limit 90