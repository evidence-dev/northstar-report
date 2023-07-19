---
title: Needful Things Northstar Report
---

<script>
import Mermaid from '../components/Mermaid.svelte';
</script>


This report contains the most important high level metrics for Needful Things' business operations.

- This report focuses on the **inputs measures** for our business, rather than the **outputs KPIs**. 
- This is becuase we have control over these inputs, and we have chosen those that are leading indicators of future performance.


# Output KPIs

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
  1.0 * aov / aov_last -1 as aov_growth,
  1 as test
from orders
group by 1
order by 1 desc
```

<Mermaid id=sales>
graph LR
  sales --> aov[$ AOV]
  sales[$ Sales] --> orders["# Orders"]
  orders --> paid-orders["Paid Orders"]
  orders --> organic-orders["Organic Orders"]
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



<br>

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

However these are not inputs we control, for that we need to dig deeper.


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
**Orders** are impacted by
  1. **Paid marketing** (volume and efficiency)
  2. **Customer experience** (which drives repeat purchases and referrals, ie organic orders)
  3. **Our capacity** to fulfill orders

  **AOV** is impacted by
  1. **Availability** of products
  2. **Range** of products
  3. **Pricing** of products

# Input KPIs

## 1. Paid Marketing



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
order by 1 desc
```


Our paid marketing spend drives our paid orders

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


<Alert status=info>
  We do not currently have a way to track paid impressions and conversion rate. This is a priority for us.
</Alert>


## 2. Customer Experience

We know that organic orders (repeat purchases and referrals) are driven by **great customer experience**.

<Mermaid id=organic>
graph LR
  organic-orders["Orders"] --> cx["Great CX"]
  cx --> repeat_and_referral["Repeat Orders & Referrals"]
  repeat_and_referral --> organic-orders
</Mermaid>

The customer experience inputs we can control are:
- Product range and availability
- Time to next available delivery slot
- On-time delivery
- Product quality

```sql range_sold
select 
  date_trunc('month', order_datetime) as month,
  count(distinct item) as range_sold
from orders
group by 1
order by 1 desc
```

```sql time_to_delivery
select
  date_trunc('month', order_datetime) as month,
  avg(extract(epoch from delivery_slot_start - order_datetime) / 60 / 60 / 24) as days_to_delivery_slot
from deliveries
group by 1
order by 1 desc
```

```sql delivery_status
select
  date_trunc('month', delivery_time) as month,
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
  month,
  SUM(CASE WHEN delivery_status = 'Early' THEN deliveries ELSE 0 END) AS early_deliveries,
  SUM(CASE WHEN delivery_status = 'Late' THEN deliveries ELSE 0 END) AS late_deliveries,
  SUM(CASE WHEN delivery_status = 'On Time' THEN deliveries ELSE 0 END) AS on_time_deliveries,
  ROUND(SUM(CASE WHEN delivery_status = 'Early' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS early_percentage,
  ROUND(SUM(CASE WHEN delivery_status = 'Late' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS late_percentage,
  ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS on_time_percentage
FROM ${delivery_status}
GROUP BY 1
ORDER BY 1 DESC
```

```sql returns_abs
select 
date_trunc('month',order_datetime) as month,
count(*) as returns
from returns
left join orders on order_id=orders.id
where reason ilike '%Quality%' 
 or reason ilike '%Damaged%' 
 or reason ilike '%Defective product%'
 or reason ilike '%wrong%'
 or reason ilike '%match%'
group by 1
order by 1 desc
```


```sql returns_percent
select 
  returns_abs.month,
  returns,
  orders,
  1.0 * returns / orders as returns_percent
from ${returns_abs} returns_abs
left join ${orders} orders on orders.month = returns_abs.month
order by 1 desc
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
  date_trunc('month', order_datetime) as month,
  avg(sales) as average_price,
  avg(sales) / lag(avg(sales)) over (order by month) -1 as average_price_growth
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