select 
  day,
  count(*) as returns
from ${returns_by_reason}
group by 1