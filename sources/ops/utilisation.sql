select 
  day,
  sum(deliveries) as deliveries_total,
  count(distinct truck_number) as trucks,
  sum(capacity) as capacity_total,
  sum(deliveries) / sum(capacity) as utilisation,
  lag(trucks) over (order by day) as trucks_last,
  lag(deliveries_total) over (order by day) as deliveries_last,
  lag(capacity_total) over (order by day) as capacity_last,
  lag(utilisation) over (order by day) as utilisation_last,
  trucks / trucks_last -1 as trucks_growth,
  deliveries_total / deliveries_last -1 as deliveries_growth,
  capacity_total / capacity_last -1 as capacity_growth,
  utilisation / utilisation_last -1 as utilisation_growth
from ${deliveries_by_truck}
group by 1
order by 1 desc
limit 90
offset 4