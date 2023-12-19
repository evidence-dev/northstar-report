select
  date_trunc('day', order_datetime) as day,
  avg(extract(epoch from delivery_slot_start - order_datetime) / 60 / 60 / 24) as days_to_delivery_slot,
  lag(days_to_delivery_slot) over (order by day) as days_to_delivery_slot_last,
  days_to_delivery_slot / days_to_delivery_slot_last -1 as days_to_delivery_slot_growth
from deliveries
group by 1
order by 1 desc
limit 90