select
  date_trunc('day', delivery_time) as day,
  case 
    when delivery_time < delivery_slot_start then 'Early'
    when delivery_time > delivery_slot_end then 'Late'
    else 'On Time'
  end as delivery_status,
  count(*) as deliveries
from deliveries
group by 1, 2
order by 1 desc