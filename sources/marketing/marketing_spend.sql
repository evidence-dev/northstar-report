select
  month_begin,
  sum(spend) as spend
from marketing_spend
group by 1
order by 1 desc
limit 90