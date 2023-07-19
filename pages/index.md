<script>
import Mermaid from '../components/Mermaid.svelte';
</script>

# Needful Things Northstar Report

This report contains the most important high level metrics for Needful Things' business operations.

## Drivers of Revenue

We break down our revenue as follows

```sql orders
select 
  date_trunc('month', order_datetime) as month,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by month) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by month) -1 as sales_growth,
  lag(sum(sales) / count(*)) over (order by month) as aov_last,
  1.0 * aov / aov_last -1 as aov_growth
from orders
group by 1
order by 1 desc
```

<Mermaid id=sales>
graph LR
  sales[$ Sales] --> orders["# Orders"]
  sales --> aov[$ AOV]
</Mermaid>



<BigValue
  data={orders}
  value=sales
  title="Total Sales"
  fmt=usd1k
  comparison=sales_growth
  comparisonFmt=pct1
/>

<BigValue
  data={orders}
  value=orders
  comparison=orders_growth
  comparisonFmt=pct1
/>


<BigValue
  data={orders}
  value=aov
  title=AOV
  fmt=usd2
  comparison=aov_growth
  comparisonFmt=pct1
/>

<br>

<BigValue
  data={paid_orders}
  value=orders
  title="Paid Orders"
/>

<BigValue
  data={organic_orders}
  value=orders
  title="Organic Orders"
/>


- \# Orders are impacted by
  1. Paid marketing
  2. Organic orders (return customers and referrals)
  3. Our capacity to fulfill orders
  
- AOV is impacted by
  1. Product availability
  2. Product range
  3. Product pricing

## Paid Marketing



```sql paid_orders
select 
  date_trunc('month', order_datetime) as month,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by month) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by month) -1 as sales_growth,
  sum(sales) / count(*) / lag(sum(sales)) over (order by month) -1 as aov_growth
from orders
where channel_group ilike '%paid%'
or channel_group ilike '%social%'
group by 1
order by 1 desc
```

```sql organic_orders
select 
  date_trunc('month', order_datetime) as month,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by month) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by month) -1 as sales_growth,
  sum(sales) / count(*) / lag(sum(sales)) over (order by month) -1 as aov_growth
from orders
where channel_group not ilike '%paid%'
and channel_group not ilike '%social%'
group by 1
order by 1 desc
```



```sql spend
select 
  month_begin,
  sum(spend) as spend
from marketing_spend
group by 1
```

```sql cpa
select 
  month_begin,
  spend,
  orders,
  spend / orders as cpa,
  --month on month change in spend and cpa
  spend / lag(spend) over (order by month_begin) -1 as spend_growth,
  cpa / lag(cpa) over (order by month_begin) -1 as cpa_growth
from ${spend}
left join ${paid_orders} on month_begin = month
```

Our paid marketing spend drives our paid orders in the following way

<Mermaid id=marketing>
graph LR
  paid-orders["Paid Orders"] --> spend["$ Spend"]
  paid-orders --> cpa["$ Cost per Acquisition"]
  cpa --> conversion["Conversion Rate %"]
  cpa --> impressions["# Impressions"]
</Mermaid>

<BigValue
  data={paid_orders}
  value=orders
  title="Paid Orders"
  comparison=orders_growth
  comparisonFmt=pct1
/>
  



<BigValue
  data={cpa}
  value=spend
  title="Total Spend"
  fmt=usd1k
/>

<BigValue
  data={cpa}
  value=cpa
  title="Cost per Acquisition"
  fmt=usd2
/>

