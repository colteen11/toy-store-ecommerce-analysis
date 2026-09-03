-- This query shows total revenue for each month

SELECT 
    EXTRACT(YEAR from created_at::Date) AS Year,
    EXTRACT(MONTH from created_at::Date) AS month,
    SUM(price_usd) AS total_revenue
FROM orders
GROUP BY (EXTRACT(YEAR from created_at::Date) , 
          EXTRACT(MONTH from created_at::Date))
ORDER BY EXTRACT(YEAR from created_at::Date), EXTRACT(MONTH from created_at::Date);


-- Total profit and profit margin

SELECT 
product_name AS Product,
sum(price_usd) AS Revenue,
sum(cogs_usd) AS cost_of_goods,
sum(price_usd) - sum(cogs_usd) AS total_profit,
round(((sum(price_usd) - sum(cogs_usd)) / sum(price_usd)) * 100, 2) AS profit_margin
FROM order_items
LEFT JOIN products ON order_items.product_id = products.product_id
GROUP BY product_name;

-- Average spent on orders
Select 
avg(price_usd) AS avg_order_price
FROM orders;

-- Profit by month
SELECT 
EXTRACT(YEAR FROM created_at) AS year,
EXTRACT(MONTH FROM created_at) AS month,
ROUND(SUM(price_usd) - sum(cogs_usd), 2) AS profit,
RANK() OVER
(ORDER BY ROUND(SUM(price_usd) - sum(cogs_usd), 2) DESC) AS Rank
FROM order_items
GROUP BY 
EXTRACT(YEAR FROM created_at),
EXTRACT(MONTH FROM created_at);

--Profit change by month

with monthly_profit AS (
   SELECT 
EXTRACT(YEAR FROM created_at) AS year,
EXTRACT(MONTH FROM created_at) AS month,
ROUND(SUM(price_usd) - sum(cogs_usd), 2) AS profit
FROM order_items
GROUP BY 
EXTRACT(YEAR FROM created_at),
EXTRACT(MONTH FROM created_at) 
),
 profit_change AS (
SELECT 
year,
month,
profit,
profit - LAG(profit) OVER( ORDER BY YEAR, MONTH) AS change_in_profit
FROM monthly_profit)

SELECT
year,
month,
profit,
change_in_profit,
ROUND((change_in_profit / LAG(profit) OVER (ORDER BY Year, MONTH)) * 100, 2) AS percent_growth,
CASE
    WHEN change_in_profit > 0 THEN 'Increase'
    WHEN change_in_profit < 0 THEN 'Decrease'
    When change_in_profit IS NULL THEN 'First Month'
    ELSE 'neautral'
END AS Growth_direction
FROM profit_change;

-- Revenue per Order by Month
SELECT 
EXTRACT(YEAR FROM created_at) AS year,
EXTRACT(MONTH FROM created_at) AS month,
COUNT(order_id) AS number_of_orders,
ROUND(AVG(price_usd), 2) AS avg_order_price
FROM orders
GROUP BY EXTRACT(YEAR FROM created_at), EXTRACT(MONTH FROM created_at);


-- Total quanity of refund
SELECT COUNT(ord.order_id) AS quantity_sold,
COUNT(oir.order_id) AS quantity_returned,
ROUND(COUNT(oir.order_id)::numeric / COUNT(ord.order_id) * 100, 2) AS percentage_returned
FROM orders ord
LEFT JOIN order_item_refunds oir ON ord.order_id = oir.order_id;

-- Number of orders by Month
SELECT
EXTRACT(YEAR from created_at) AS year,
EXTRACT(MONTH from created_at) AS month,
COUNT(order_id)
FROM orders
GROUP BY EXTRACT(YEAR from created_at), Extract(MONTH from created_at)
ORDER BY EXTRACT(YEAR from created_at), Extract(MONTH from created_at);


--Power Bi line chart

SELECT 
EXTRACT(YEAR FROM created_at) AS year,
EXTRACT(MONTH FROM created_at) AS month,
make_date(EXTRACT(YEAR FROM created_at)::INT, EXTRACT(MONTH FROM created_at)::INT, 1) AS real_date,
SUM(price_usd) AS Revenue,
SUM(cogs_usd) AS Cost_of_Goods
FROM orders
GROUP BY EXTRACT(YEAR FROM created_at), EXTRACT(MONTH FROM created_at)
ORDER BY EXTRACT(YEAR FROM created_at), EXTRACT(Month FROM created_at)
