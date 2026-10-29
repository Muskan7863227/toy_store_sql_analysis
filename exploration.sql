USE Toy_Store;
GO

---Data types checks
SELECT TABLE_NAME,COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
'orders',
'order_items',
'order_items_refunds',
'products',
'website_sessions',
'website_pageviews'
)
ORDER BY TABLE_NAME,ORDINAL_POSITION;

---changing money columns to decimal(10,2) ,so revenue sums exact
ALTER TABLE order_items ALTER COLUMN cogs_usd DECIMAL(10,2) NOT NULL;
ALTER TABLE order_items ALTER COLUMN price_usd DECIMAL(10,2) NOT NULL;
ALTER TABLE orders ALTER COLUMN cogs_usd DECIMAL(10,2) NOT NULL;
ALTER TABLE orders ALTER COLUMN price_usd DECIMAL(10,2) NOT NULL;

---understanding tables
SELECT top(10)* FROM dbo.products;
SELECT top(10)* FROM dbo.orders;
SELECT top(10)* FROM dbo.order_item_refunds;
SELECT top(10)* FROM dbo.order_items;
SELECT top(10)* FROM dbo.website_pageviews;
SELECT top(10)* FROM dbo.website_sessions;

