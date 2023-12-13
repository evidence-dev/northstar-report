select 
  STRPTIME(SUBSTR(delivery_slot_start, 1, 23), '%a %b %d %Y %T') AS delivery_slot_start_parsed,
  date_trunc('day', delivery_slot_start_parsed) as day,
  truck_number,
  capacity,
  count(*) as deliveries,
  
from deliveries
left join trucks on deliveries.truck_number = trucks.id
group by 1,2,3