-- looking at return customer value
SELECT AVG(order_count) avg_orders,
  AVG(total_value) avg_customer_value,
  AVG(time_to_next_order),
  AVG(total_discounts) avg_discount,
  AVG(discounts_used)*100.0 pct_used_discount,
  sent_card,
  COUNT(*) orders
FROM (
  SELECT o.*, p.sent as sent_card
  FROM (
    SELECT customer_id, count(*) as order_count,
      SUM(total_price - total_discounts)/100 as total_value,
      SUM((postcard_id IS NOT NULL)::Integer) as attributed_postcard,
      MAX(created_at) - MIN(created_at) as time_to_next_order,
      SUM(total_discounts)/100 as total_discounts,
      MIN(id) as initial_order_id,
      SUM((total_discounts > 0)::INTEGER) as discounts_used
    FROM orders
    WHERE shop_id = 4
    GROUP BY customer_id
  ) o
  LEFT JOIN postcards p
  ON p.customer_id = o.customer_id
  WHERE p.sent = TRUE OR p.sent IS NULL
  ORDER BY sent_card
) X
GROUP BY sent_card;
