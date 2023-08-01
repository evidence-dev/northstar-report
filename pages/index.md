---
title: Northstar Report
hide_title: true
sources:
  - orders: orders.sql
  - orders_2021: orders_2021.sql
  - paid_orders: marketing/paid_orders.sql
  - organic_orders: marketing/organic_orders.sql
  - dates: marketing/dates.sql
  - marketing_spend: marketing/marketing_spend.sql
  - spend: marketing/spend.sql
  - cpa: marketing/cpa.sql
  - range_sold: merch/range_sold.sql
  - average_price: merch/average_price.sql
  - time_to_delivery: product-cs/time_to_delivery.sql
  - delivery_on_time: product-cs/delivery_on_time.sql
  - delivery_status: product-cs/delivery_status.sql
  - returns_by_reason: product-cs/returns_by_reason.sql
  - monthly_returns_by_reason: product-cs/monthly_returns_by_reason.sql
  - returns_abs: product-cs/returns_abs.sql
  - returns_percent: product-cs/returns_percent.sql
  - utilisation: ops/utilisation.sql
  - deliveries_by_truck: ops/deliveries_by_truck.sql
---

<script>
  import Mermaid from '../components/Mermaid.svelte';
  import Details from '../components/Details.svelte';
  import GithubStarCount from '../components/GithubStarCount.svelte';
</script>

# Northstar Report <GithubStarCount user=evidence-dev repo=northstar-report/>


This report shows the most important daily metrics for our business.


## 🌟 Average Order Value

<LineChart 
  data={orders_2021} 
  x=day 
  y=aov 
  yFmt=usd0
  title="AOV, 2021"
>
  <ReferenceArea yMin='33' label='Exceeds Target' color=green labelPosition=topRight/>
  <ReferenceArea yMin='24' yMax='33' label='Meets Target' color=yellow labelPosition=bottomRight/>
  <ReferenceArea yMax='24' label='Below Target' color=red/>
  <ReferenceLine y='29.5' yMax='40' label='Budget' labelPosition=belowStart/>
</LineChart>


AOV is our key northstar metric as it is highly aligned with *how much value we deliver* to customers.

<Details title=Definition>


AOV is the *Average Order Value*, the amount a customer spends on an order, net of tax. It excludes B2B revenue which otherwise skews the metric siginificantly.

</Details>


## Output KPIs


<Details title="Why these metrics?">


We can break down our revenue as follows:

<Mermaid id=sales>
graph LR
  sales --> aov[$ AOV]
  sales[$ Sales] --> orders["# Orders"]
  orders --> paid-orders["# Paid Orders"]
  orders --> organic-orders["# Organic Orders"]
</Mermaid>

</Details>



<BigValue
  data={orders}
  value=sales
  title="Total Sales"
  fmt=usd1k
  comparison=sales_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>

<BigValue
  data={orders}
  value=aov
  title=AOV
  fmt=usd2
  comparison=aov_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>


<BigValue
  data={orders}
  value=orders
  comparison=orders_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>

<br>

<BigValue
  data={paid_orders}
  value=orders
  title="Paid Orders"
  comparison=orders_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>

<BigValue
  data={organic_orders}
  value=orders
  title="Organic Orders"
  comparison=orders_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>



<Details title="Show Charts">


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



</Details>




## Input KPIs

<Details title="Why these groups?">


Revenue is are impacted by:
  1. **Paid marketing** (volume and efficiency)
  2. **Customer experience** (which drives repeat purchases and referrals, ie organic orders)
  3. **Capacity** we have to fulfill orders
  4. **Product Offering** including range, availability and price


</Details>

---

### 1. Paid Marketing (Marketing team)





<BigValue
  data={paid_orders}
  value=orders
  title="Paid Orders"
  comparison=orders_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>

<BigValue
  data={cpa}
  value=allocated_spend
  title="Total Spend"
  fmt=usd1k
  comparison=spend_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>

<BigValue
  data={cpa}
  value=cpa
  title="Cost / Acq."
  fmt=usd2
  comparison=cpa_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
  downIsGood=true
/>

<Details title="Why these metrics?">


Our paid marketing spend drives our paid orders

<Mermaid id=marketing>
graph LR
  paid-orders["# Paid Orders"] --> spend["$ Spend"]
  paid-orders --> cpa["$ Cost per Acquisition"]
  cpa --> conversion["Conversion Rate %"]
  cpa --> impressions["# Impressions"]
</Mermaid>

<Alert status=info>
  We do not currently have a way to track paid impressions and conversion rates. This is a priority for us.
</Alert>


</Details>

<BigLink href='/1.-marketing'>
  More Detail &rarr;
</BigLink>

### 2. Customer Experience (Product & Customer Service teams)





<BigValue
  data={time_to_delivery}
  value=days_to_delivery_slot
  title="Next Slot"
  fmt='0.00" days"'
  comparison=days_to_delivery_slot_growth
  comparisonFmt=pct1
  comparisonTitle="growth"
  downIsGood=true
/>

<BigValue
  data={delivery_on_time}
  value=on_time_percentage
  title="On Time %"
  fmt=pct
  comparison=on_time_percentage_delta
  comparisonFmt=pct1
  comparisonTitle="delta"
/>

<BigValue
  data={returns_percent}
  value=returns_percent
  title="Returns %*"
  fmt=pct1
  comparison=returns_percent_delta
  comparisonFmt=pct1
  comparisonTitle="delta"
  downIsGood=true
/>

<small>

\* Returns where customer gave a reason that indicates poor customer experience, e.g. quality, damaged, wrong item, etc.

</small>

<Details title="Why these metrics?">

We know that organic orders (repeat purchases and referrals) are driven by **great customer experience**.

<Mermaid id=organic>
graph LR
  organic-orders["Orders"]-->cx["Great CX"]
  cx-->repeat_and_referral["Repeat Orders & Referrals"]
  repeat_and_referral-->organic-orders
</Mermaid>

The customer experience inputs we can control are:
- Speed to getting products
- Convenience of delivery
- Quality of products
- Range of available products (see merch team)

We tie one metric to each of these inputs.

</Details>


<BigLink href='/2.-product-&-customer-service'>
  More Detail &rarr;
</BigLink>

### 3. Capacity (Ops Team)



<BigValue
  data={utilisation}
  value=trucks
  title="Trucks"
  comparison=trucks_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>

<BigValue
  data={utilisation}
  value=capacity_total
  title="Delivery Capacity*"
  comparison=capacity_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>

<BigValue
  data={utilisation}
  value=deliveries_total
  title="Deliveries"
  comparison=deliveries_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>


<BigValue
  data={utilisation}
  value=utilisation
  title="Truck Utilisation"
  fmt=pct
  comparison=utilisation_growth
  comparisonFmt=pct0
  comparisonTitle="growth"
/>

<small>

\* This assumes an empirical capacity of 10 deliveries per truck per day. In reality this depends on the size of items and the routes.

</small>

<Details title="Why these metrics?">

It is important to manage our capacity:
- **Enough**: So we deliver short lead times for our customers, and drivers shifts are not too full
- **Not too much:** So we don't pay for unused capacity

</Details>

<BigLink href='/3.-ops'>
  More Detail &rarr;
</BigLink>

### 4. Product Offering (Merch team)

<BigValue
  data={range_sold}
  value=range_sold
  title="Product Lines"
  comparison=range_sold_growth
  comparisonFmt=pct1
  comparisonTitle="growth"
/>

<BigValue
  data={average_price}
  value=average_price
  title="Average Price*"
  fmt=usd2
  comparison=average_price_growth
  comparisonFmt=pct1
  comparisonTitle="growth"
/>

<small>

\* Our website currently limits customers to buying one item per order, meaning average price is the same as AOV. Allowing multiple items per order should significantly increase AOV.

</small>


<Details title="Why these metrics?">

Ideally we would measure the following
- **Range**: Number of products available to customers
- **Availability**: Number of products in stock
- **Price**: Average price of products

but currently we do not have data on availability.

</Details>


<BigLink href='/4.-merch'>
  More Detail &rarr;
</BigLink>