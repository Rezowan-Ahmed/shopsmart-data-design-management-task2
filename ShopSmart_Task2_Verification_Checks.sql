-- ShopSmart Task 2: POST-RUN CHECKS (read only)
-- Run AFTER ShopSmart_Task2_Complete.sql in a fresh database.
SELECT current_database() AS connected_database;

SELECT 'categories' AS table_name, COUNT(*) AS records FROM categories
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
ORDER BY table_name;

SELECT COUNT(*) AS total_records FROM (
 SELECT 1 FROM categories UNION ALL SELECT 1 FROM customers
 UNION ALL SELECT 1 FROM employees UNION ALL SELECT 1 FROM inventory
 UNION ALL SELECT 1 FROM order_items UNION ALL SELECT 1 FROM orders
 UNION ALL SELECT 1 FROM payments UNION ALL SELECT 1 FROM products
 UNION ALL SELECT 1 FROM suppliers
) t;

SELECT COUNT(*) FILTER (WHERE i.stock_quantity <= i.reorder_level) AS reorder_alerts,
 COUNT(*) FILTER (WHERE i.stock_quantity=0) AS out_of_stock,
 COUNT(*) AS products_tracked
FROM inventory i JOIN products p ON p.product_id=i.product_id
WHERE p.is_active = TRUE;

WITH o AS (SELECT orders.order_id, SUM(oi.quantity * oi.unit_price) AS total
 FROM orders LEFT JOIN order_items oi ON oi.order_id=orders.order_id
 GROUP BY orders.order_id)
SELECT COUNT(*) AS orders_checked,
 COUNT(*) FILTER (WHERE total IS NULL) AS orders_without_items,
 COUNT(*) FILTER (WHERE p.payment_id IS NULL) AS orders_without_payment,
 COUNT(*) FILTER (WHERE p.payment_id IS NOT NULL AND p.amount <> o.total) AS mismatches
FROM o LEFT JOIN payments p ON p.order_id=o.order_id;

SELECT 'shopsmart_monthly_sales' AS view_name, COUNT(*) AS rows
FROM shopsmart_monthly_sales
UNION ALL SELECT 'shopsmart_inventory_category_summary', COUNT(*)
FROM shopsmart_inventory_category_summary;

SELECT TO_CHAR(month_start,'YYYY-MM') AS sales_month,total_orders,units_sold,revenue_gbp
FROM shopsmart_monthly_sales ORDER BY month_start;

WITH a AS (SELECT SUM(products_tracked) AS products, SUM(products_at_reorder) AS alerts
 FROM shopsmart_inventory_category_summary),
 b AS (SELECT COUNT(*) AS products,COUNT(*) FILTER (WHERE i.stock_quantity <= i.reorder_level) AS alerts
 FROM inventory i JOIN products p ON p.product_id=i.product_id WHERE p.is_active)
SELECT a.products AS summary_products,b.products AS source_products,
 a.alerts AS summary_alerts,b.alerts AS source_alerts,
 CASE WHEN a.products=b.products AND a.alerts=b.alerts THEN 'MATCH' ELSE 'MISMATCH' END AS status
FROM a CROSS JOIN b;
