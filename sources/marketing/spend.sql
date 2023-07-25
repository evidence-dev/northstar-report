select 
  dates.date,
  count(*) over (partition by date_trunc('month', dates.date)) as days,
  sum(marketing_spend.spend) over (partition by date_trunc('month', dates.date)) / count(*) over (partition by date_trunc('month', dates.date)) as allocated_spend
from ${dates} as dates
left join ${marketing_spend} as marketing_spend 
  on dates.date = marketing_spend.month_begin
order by 1 desc
limit 90