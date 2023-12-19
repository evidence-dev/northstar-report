select
  date_trunc('month', day) as month_num,
  monthname(day) as month,
  reason,
  sum(returns) as returns
from ${returns_by_reason}
group by 1,2,3
order by 1