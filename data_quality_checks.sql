
-- 1. Row counts
SELECT 'website_sessions' AS Table_Name, COUNT(*) AS Row_Count FROM dbo.website_sessions
UNION ALL
SELECT 'website_pageviews', COUNT(*) FROM dbo.website_pageviews
UNION ALL
SELECT 'products', COUNT(*) FROM dbo.products
UNION ALL
SELECT 'orders', COUNT(*) FROM dbo.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM dbo.order_items
UNION ALL
SELECT 'order_item_refunds', COUNT(*) FROM dbo.order_item_refunds;

--2.Date Range
SELECT 
    MIN(created_at) AS First_order,
    MAX(created_at) AS Last_order
FROM orders;

-- 3. DUPLICATE CHECK: PRIMARY KEY
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

---4.NULLS checks on orders table
SELECT 
       SUM(case when order_id is null then 1 else 0 end) as missing_order_id,
       sum(case when user_id is null then 1 else 0 end ) as missing_user_ids,
       sum(case when website_session_id is null then 1 else 0 end ) as missing_session_ids,
       sum(case when created_at is null then 1 else 0 end) as missing_dates,
        sum(case when price_usd is null  then 1 else 0 end ) as missing_prices,
       sum(case when cogs_usd is null then 1 else 0 end) as missing_cogs
from orders;

--5.nulls checks on utm_source
SELECT COUNT(*) AS null_utm_source
FROM website_sessions
WHERE utm_source IS NULL;

---6.comforing the len 
SELECT utm_source,
       lEN(utm_source) as txt_length,
       count(*) AS cnt
FROM website_sessions
GROUP BY utm_source
ORDER BY cnt DESC

-- 7. INTEGRITY CHECK: ORPHAN KEYS (Critical Relational Check)
SELECT COUNT(o.order_id) AS Orphaned_Orders_Count
FROM dbo.orders o
LEFT JOIN dbo.website_sessions s ON o.website_session_id = s.website_session_id
WHERE s.website_session_id IS NULL;


-- 8. INTEGRITY CHECK: ORPHANED REFUNDS
SELECT COUNT(*) AS Orphaned_Refund_Logs
FROM order_item_refunds rf
LEFT JOIN order_items oi on rf.order_item_id=oi.order_item_id
WHERE oi.order_item_id IS NULL;


-- 9. DUPLICATE CHECK: PRIMARY KEY INTEGRITY
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

---10.SUSPICIOUS ROWS
select COUNT(*) AS suspicious_count
FROM Orders 
WHERE price_usd<=0 OR cogs_usd<0 OR cogs_usd>price_usd;

