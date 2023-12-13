select
  STRPTIME(SUBSTR(delivery_slot_start, 1, 23), '%a %b %d %Y %T') AS delivery_slot_start_parsed,
  STRPTIME(SUBSTR(delivery_slot_end, 1, 23), '%a %b %d %Y %T') AS delivery_slot_end_parsed,
  STRPTIME(SUBSTR(delivery_time, 1, 23), '%a %b %d %Y %T') AS delivery_time_parsed,
  date_trunc('day', delivery_time_parsed) as day,
  case 
    when delivery_time_parsed < delivery_slot_start_parsed then 'Early'
    when delivery_time_parsed > delivery_slot_end_parsed then 'Late'
    else 'On Time'
  end as delivery_status,
  count(*) as deliveries
from deliveries
group by all
order by 1 desc