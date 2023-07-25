select 
date_trunc('day',order_datetime) as day,
reason,
count(*) as returns
from returns
left join orders on order_id=orders.id
where reason ilike '%Quality%' 
 or reason ilike '%Damaged%' 
 or reason ilike '%Defective product%'
 or reason ilike '%wrong%'
 or reason ilike '%match%'
group by 1,2
order by 1 desc
limit 90*5