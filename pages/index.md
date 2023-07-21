---
title: Northstar Report
---

<script>
import Mermaid from '../components/Mermaid.svelte';
</script>


This report contains the most important daily high level metrics for Needful Things' business operations.

<details>
<summary>Motivation</summary>

- This report focuses on the inputs measures for our business, rather than the outputs KPIs. 
- This is becuase we have control over these inputs, and we have chosen those that are leading indicators of future performance.

</details>

# Output KPIs


<details>
<summary>Why these metrics?</summary>

We can break down our revenue as follows:

<Mermaid id=sales>
graph LR
  sales --> aov[$ AOV]
  sales[$ Sales] --> orders["# Orders"]
  orders --> paid-orders["Paid Orders"]
  orders --> organic-orders["Organic Orders"]
</Mermaid>

</details>


```sql orders
select 
  date_trunc('day', order_datetime) as day,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by day) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by day) -1 as sales_growth,
  lag(sum(sales) / count(*)) over (order by day) as aov_last,
  1.0 * aov / aov_last -1 as aov_growth,
  1 as test
from orders
group by 1
order by 1 desc
limit 90
```




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
  value=aov
  title=AOV
  fmt=usd2
  comparison=aov_growth
  comparisonFmt=pct1
/>


<BigValue
  data={orders}
  value=orders
  comparison=orders_growth
  comparisonFmt=pct1
/>


<BigValue
  data={paid_orders}
  value=orders
  title="Paid Orders"
  comparison=orders_growth
  comparisonFmt=pct1
/>

<BigValue
  data={organic_orders}
  value=orders
  title="Organic Orders"
  comparison=orders_growth
  comparisonFmt=pct1
/>



<details>
<summary>Show Charts</summary>


<BarChart
  data={orders}
  title="Sales, Last 90 Days"
  x=day
  y=sales
  yFmt=usd
/>


<BarChart
  data={orders}
  title="AOV, Last 90 Days"
  x=day
  y=aov
  yFmt=usd0
/>


<BarChart
  data={orders}
  title="Orders, Last 90 Days"
  x=day
  y=orders
/>

<BarChart
  data={paid_orders}
  title="Paid Orders, Last 90 Days"
  x=day
  y=orders
/>

<BarChart
  data={organic_orders}
  title="Organic Orders, Last 90 Days"
  x=day
  y=orders
/>



</details>




# Input KPIs

<details>
<summary>Why these 6 groups?</summary>


**Orders** are impacted by
  1. **Paid marketing** (volume and efficiency)
  2. **Customer experience** (which drives repeat purchases and referrals, ie organic orders)
  3. **Our capacity** to fulfill orders

**AOV** is impacted by
  1. **Availability** of products
  2. **Range** of products
  3. **Pricing** of products


</details>

## 1. Paid Marketing



```sql paid_orders
select 
  date_trunc('day', order_datetime) as day,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by day) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by day) -1 as sales_growth,
  sum(sales) / count(*) / lag(sum(sales)) over (order by day) -1 as aov_growth
from orders
where channel_group ilike '%paid%'
or channel_group ilike '%social%'
group by 1
order by 1 desc
limit 90
```

```sql organic_orders
select 
  date_trunc('day', order_datetime) as day,
  count(*) as orders,
  sum(sales) as sales,
  sum(sales) / count(*) as aov,
  -- growth
  count(*) / lag(count(*)) over (order by day) -1 as orders_growth,
  sum(sales) / lag(sum(sales)) over (order by day) -1 as sales_growth,
  sum(sales) / count(*) / lag(sum(sales)) over (order by day) -1 as aov_growth
from orders
where channel_group not ilike '%paid%'
and channel_group not ilike '%social%'
group by 1
order by 1 desc
limit 90
```

```sql dates
select 
  range as date 
  from range(TIMESTAMP '2019-01-01', TIMESTAMP '2022-01-01', INTERVAL 1 DAY)
```

```sql marketing_spend
select
  month_begin,
  sum(spend) as spend
from marketing_spend
group by 1
order by 1 desc
limit 90
```


```sql spend
select 
  dates.date,
  count(*) over (partition by date_trunc('month', dates.date)) as days,
  sum(marketing_spend.spend) over (partition by date_trunc('month', dates.date)) / count(*) over (partition by date_trunc('month', dates.date)) as allocated_spend
from ${dates} as dates
left join ${marketing_spend} as marketing_spend 
  on dates.date = marketing_spend.month_begin
order by 1 desc
limit 90
```

```sql cpa
select 
  date,
  allocated_spend,
  orders,
  allocated_spend / orders as cpa,
  --day on day change in spend and cpa
  allocated_spend / lag(allocated_spend) over (order by date) -1 as spend_growth,
  cpa / lag(cpa) over (order by date) -1 as cpa_growth
from ${spend}
left join ${paid_orders} on date = day
order by 1 desc
limit 90
```




<details>
<summary>Why these metrics?</summary>


Our paid marketing spend drives our paid orders

<Mermaid id=marketing>
graph LR
  paid-orders["Paid Orders"] --> spend["$ Spend"]
  paid-orders --> cpa["$ Cost per Acquisition"]
  cpa --> conversion["Conversion Rate %"]
  cpa --> impressions["# Impressions"]
</Mermaid>

<Alert status=info>
  We do not currently have a way to track paid impressions and conversion rate. This is a priority for us.
</Alert>


</details>



<BigValue
  data={paid_orders}
  value=orders
  title="Paid Orders"
  comparison=orders_growth
  comparisonFmt=pct1
/>

<BigValue
  data={cpa}
  value=allocated_spend
  title="Total Spend"
  fmt=usd1k
  comparison=spend_growth
  comparisonFmt=pct1
/>

<BigValue
  data={cpa}
  value=cpa
  title="Cost per Acquisition"
  fmt=usd2
  comparison=cpa_growth
  comparisonFmt=pct1
/>


<details>
<summary>Show Charts</summary>

<BarChart
  data={paid_orders}
  title="Paid Orders, Last 90 Days"
  x=day
  y=orders
/>

<BarChart
  data={cpa}
  title="CPA, Last 90 Days"
  x=date
  y=cpa
  yFmt=usd2
/>

<BarChart
  data={cpa}
  title="Spend, Last 90 Days"
  x=date
  y=allocated_spend
  yFmt=usd1k
/>

NB monthly spend totals are allocated evenly across days in the month.

</details>




## 2. Customer Experience

<details>
<summary>Why these metrics?</summary>

We know that organic orders (repeat purchases and referrals) are driven by **great customer experience**.

<Mermaid id=organic>
graph LR
  organic-orders["Orders"]-->cx["Great CX"]
  cx-->repeat_and_referral["Repeat Orders & Referrals"]
  repeat_and_referral-->organic-orders
</Mermaid>

The customer experience inputs we can control are:
- Range of available products
- Speed to getting products
- Convenience of delivery
- Quality of products

We tie one metric to each of these inputs.

</details>



```sql range_sold
select 
  date_trunc('day', order_datetime) as day,
  count(distinct item) as range_sold
from orders
group by 1
order by 1 desc
limit 90
```

```sql time_to_delivery
select
  date_trunc('day', order_datetime) as day,
  avg(extract(epoch from delivery_slot_start - order_datetime) / 60 / 60 / 24) as days_to_delivery_slot
from deliveries
group by 1
order by 1 desc
limit 90
```

```sql delivery_status
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
```


```sql delivery_on_time
SELECT
  day,
  SUM(CASE WHEN delivery_status = 'Early' THEN deliveries ELSE 0 END) AS early_deliveries,
  SUM(CASE WHEN delivery_status = 'Late' THEN deliveries ELSE 0 END) AS late_deliveries,
  SUM(CASE WHEN delivery_status = 'On Time' THEN deliveries ELSE 0 END) AS on_time_deliveries,
  ROUND(SUM(CASE WHEN delivery_status = 'Early' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS early_percentage,
  ROUND(SUM(CASE WHEN delivery_status = 'Late' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS late_percentage,
  ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS on_time_percentage
FROM ${delivery_status}
GROUP BY 1
ORDER BY 1 DESC
limit 90
```

```sql returns_by_by_reason
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
```

```sql monthly_returns_by_reason
select
  date_trunc('month', day) as month_num,
  monthname(day) as month,
  reason,
  sum(returns) as returns
from ${returns_by_by_reason}
group by 1,2,3
order by 1
```

```sql returns_abs
select 
  day,
  count(*) as returns
from ${returns_by_by_reason}
group by 1
```



```sql returns_percent
select 
  returns_abs.day,
  returns,
  orders,
  1.0 * returns / orders as returns_percent
from ${returns_abs} returns_abs
left join ${orders} orders on orders.day = returns_abs.day
order by 1 desc
limit 90
```




<BigValue
  data={range_sold}
  value=range_sold
  title="Products Lines Available"
/>

<BigValue
  data={time_to_delivery}
  value=days_to_delivery_slot
  title="Avg Days to Next Delivery Slot"
/>

<BigValue
  data={delivery_on_time}
  value=on_time_percentage
  title="On Time Delivery %"
  fmt=pct1
/>

<BigValue
  data={returns_percent}
  value=returns_percent
  title="Returns Due to Poor CX%"
  fmt=pct1
/>

<details>
<summary>Show Charts</summary>

<BarChart
  data={range_sold}
  title="Products Lines Available, Last 90 Days"
  x=day
  y=range_sold
/>

<LineChart
  data={time_to_delivery}
  title="Avg Days to Next Delivery Slot, Last 90 Days"
  x=day
  y=days_to_delivery_slot
/>

<LineChart
  data={delivery_on_time}
  title="On Time Delivery %, Last 90 Days"
  x=day
  y=on_time_percentage
  yFmt=pct1
/>

<BarChart
  data={returns_percent}
  title="Returns Due to Poor CX%, Last 90 Days"
  x=day
  y=returns_percent
  yFmt=pct1
/>

<BarChart
  data={monthly_returns_by_reason}
  title="Returns by Reason, Last 90 Days"
  x=month
  y=returns
  series=reason
  type=grouped
/>

</details>


## 3. Capacity

It is important to manage our capcity:
- **Enough**: So that we deliver short lead-times for our customers
- **Not too much**: So that we don't pay for unused capacity

<Alert status=warning>
  Utilisation reporting is WIP
</Alert>

## 4. Product Pricing

```sql average_price
select 
  date_trunc('day', order_datetime) as day,
  avg(sales) as average_price,
  avg(sales) / lag(avg(sales)) over (order by day) -1 as average_price_growth
from orders
group by 1 
order by 1 desc
```

<BigValue
  data={average_price}
  value=average_price
  title="Average Price"
  fmt=usd2
  comparison=average_price_growth
  comparisonFmt=pct1
/>

Note that our website currently limits customers to buying one item per order, meaning that our average price is the same as our AOV.

Allowing multiple items per order should significantly increase our AOV.

## 5. Product Range

See Customer Experience section above

## 6. Product Availability

We are currently working on a way to track this.