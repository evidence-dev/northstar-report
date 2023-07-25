select 
  date_trunc('day', delivery_slot_start) as day,
  truck_number,
  capacity,
  count(*) as deliveries,
  
from deliveries
left join trucks on deliveries.truck_number = trucks.id
group by 1,2,3