SELECT
  day,
  SUM(CASE WHEN delivery_status = 'Early' THEN deliveries ELSE 0 END) AS early_deliveries,
  SUM(CASE WHEN delivery_status = 'Late' THEN deliveries ELSE 0 END) AS late_deliveries,
  SUM(CASE WHEN delivery_status = 'On Time' THEN deliveries ELSE 0 END) AS on_time_deliveries,
  ROUND(SUM(CASE WHEN delivery_status = 'Early' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS early_percentage,
  ROUND(SUM(CASE WHEN delivery_status = 'Late' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS late_percentage,
  ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN deliveries ELSE 0 END) / SUM(deliveries), 2) AS on_time_percentage,
  lag(ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN deliveries ELSE 0 END) / SUM(deliveries), 2)) over (order by day) as on_time_percentage_last,
  on_time_percentage - on_time_percentage_last as on_time_percentage_delta
FROM ${delivery_status}
GROUP BY 1
ORDER BY 1 DESC
limit 90