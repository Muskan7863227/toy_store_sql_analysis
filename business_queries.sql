
-- Level 1: Beginner to Intermediate

-- 1. How many total orders were placed each month?
SELECT TOP(20)
       YEAR(created_at) as Year,
       MONTH(created_at) as Month,
       COUNT(order_id) as Total_Orders
FROM orders
GROUP BY YEAR(created_at),month(created_at)
ORDER BY Year,Month ASC ;

-- 2. How did monthly revenue change over time?
SELECT 
     YEAR(created_at) AS Year,
     DATENAME(MONTH,created_at) AS Month_Name,
     SUM(price_usd) AS Revenue
FROM Orders
GROUP BY
      YEAR(created_at),
      DATENAME(MONTH,created_at)
 ORDER BY Year,Month_Name ASC;

-- 3. Which products generated the highest revenue?
SELECT  p.product_id,p.product_name,ROUND(SUM(oi.price_usd),2) AS Highest_Revenue
FROM order_items oi
INNER JOIN products p on oi.product_id=p.product_id
GROUP BY 
       p.product_id,p.product_name
ORDER BY Highest_Revenue DESC;

-- 4. Which products sold the most units?
SELECT p.product_name,COUNT(order_item_id) AS Sold_Units
FROM Order_items oi
INNER JOIN products p on oi.product_id=p.product_id
GROUP BY p.product_name
ORDER BY sold_units desc;

-- 5. What is the average order value (AOV) for the business?
SELECT
       SUM(price_usd)/COUNT(order_id) AS AOV
FROM orders;

-- 6. How many unique customers placed orders?
SELECT COUNT(DISTINCT user_id) AS unique_customers
FROM orders;

-- 7. How many customers placed more than one order?
SELECT COUNT(*) AS Repeat_Customers
FROM(
SELECT user_id
FROM Orders
GROUP BY User_id
HAVING COUNT(order_id)>1
) AS Customer_count;


-- 8. How many website sessions occurred each month,
--    and how many resulted in orders?
SELECT top 20 YEAR(ws.created_at) AS Year,
       MONTH(ws.created_at) AS Month,
       COUNT(DISTINCT ws.website_session_id) AS website_session_count,
       COUNT(DISTINCT o.order_id) AS no_of_orders
FROM website_sessions ws
LEFT JOIN orders o on ws.website_session_id=o.website_session_id
GROUP BY Year(ws.created_at),
         MONTH(ws.created_at)
ORDER BY website_session_count DESC,no_of_orders DESC;       

-- 9. What percentage of website sessions converted into orders?
SELECT 
       CAST((COUNT(o.order_id)*100.0)/
         COUNT(ws.website_session_id) AS DECIMAL(5,2)) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o on ws.website_session_id=o.website_session_id;

-- 10. Which traffic sources generated the most website sessions and orders?
SELECT 
       COALESCE(NULLIF(LTRIM(RTRIM(ws.utm_source)),'NULL'),'Unknown') AS utm_source,
       COUNT(ws.website_session_id)AS sessions_count,
       COUNT(o.order_id) as order_count
FROM website_sessions ws
LEFT JOIN orders o on ws.website_session_id=o.website_session_id
GROUP BY COALESCE(NULLIF(LTRIM(RTRIM(ws.utm_source)),'NULL'),'Unknown')
ORDER BY sessions_count DESC,order_count DESC;

-- 11. Which landing pages had the highest conversion rates?
WITH first_pageviews AS(
        SELECT website_session_id,
               MIN(website_pageview_id) AS min_pagev_id
        FROM website_pageviews 
GROUP BY website_session_id
),landing_pages AS (
 SELECT 
        fp.website_session_id,
        wp.pageview_url as landing_page
 FROM first_pageviews fp
 JOIN website_pageviews wp on fp.min_pagev_id=wp.website_session_id
), session_orders AS(
     select distinct website_session_id
     from orders
     )
SELECT lp.landing_page,
       COUNT(DISTINCT lp.website_session_id) AS total_sessions,
       COUNT(DISTINCT so.website_session_id) AS converted_sessions,
       CAST(COUNT(so.website_session_id)*100.0/
       COUNT(*)AS DECIMAL(5,2)) AS Conversion_rate
FROM landing_pages lp
LEFT JOIN session_orders so
ON lp.website_session_id=so.website_session_id
GROUP BY lp.landing_page
ORDER BY conversion_rate DESC;

-- 12. Which products generated the highest refund amounts?
SELECT p.product_id,p.product_name,ROUND(SUM(rif.refund_amount_usd),2) AS Refund_amount
FROM order_item_refunds rif
JOIN order_items oi on rif.order_item_id=oi.order_item_id
JOIN products p on oi.product_id=p.product_id
GROUP BY p.product_id,p.product_name
ORDER BY Refund_amount DESC;

-- 13. What percentage of orders resulted in refunds?
 WITH results AS(
 SELECT COUNT(DISTINCT o.order_id) AS Total_orders,
       COUNT(DISTINCT oir.ORDER_id) AS refunded_orders
FROM orders o
left Join order_item_refunds oir on o.order_id=oir.order_id
)
SELECT 
      CAST(refunded_orders*100.0/total_orders AS DECIMAL(5,2))  AS refund_percentage
FROM results;

-- 14. Which products contribute the highest percentage of total revenue?
SELECT 
     product_name,
     SUM(oi.price_usd) AS Product_revenue,
     ROUND(SUM(oi.price_usd)/SUM(SUM(oi.price_usd)) over()*100.0,2) AS per_revenue
FROM order_items oi
LEFT JOIN products p on oi.product_id=p.product_id
GROUP BY product_name
ORDER BY per_revenue DESC;


-- 15. How much revenue does each traffic source generate?
SELECT COALESCE(NULLIF(LTRIM(RTRIM(ws.utm_source)),'NULL'),'Unknown') AS utm_source,SUM(o.price_usd) AS Revenue
FROM website_sessions ws
LEFT join orders o on ws.website_session_id=o.website_session_id
GROUP BY COALESCE(NULLIF(LTRIM(RTRIM(ws.utm_source)),'NULL'),'Unknown')
ORDER BY Revenue DESC;

-- 17. Which months had the highest and lowest order counts?
 WITH RankedMonths AS(
 SELECT 
       YEAR(created_at) AS Year,
       MONTH(created_at) AS Month,
       COUNT(order_id) AS total_order,
       RANK() OVER(ORDER BY COUNT(order_id) DESC) AS Highest_rank,
       RANK() OVER(ORDER BY COUNT(order_id) ASC) AS Lowest_rank
FROM orders
GROUP BY 
       YEAR(created_at),
       MONTH(created_at)
) 
select
    Year,
    Month,
    total_order,
    CASE WHEN highest_rank=1 THEN 'Highest' ELSE 'Lowest' END AS Type
FROM RankedMonths
WHERE Highest_rank=1 OR Lowest_rank=1;


