-- ============================================================
--  YANKI E-COMMERCE — SQL VERIFICATION & BUSINESS ANALYSIS
--  Database: PostgreSQL | Schema: yanki
--  Run these after the ETL pipeline has loaded all 5 tables
-- ============================================================


-- ============================================================
-- SECTION 1: PIPELINE VERIFICATION
-- Confirm data loaded correctly before doing any analysis.
-- These are the first queries you always run after an ETL load.
-- ============================================================

-- 1.1 Row counts — verify all 1,000 records loaded into each table
SELECT 'customers'       AS table_name, COUNT(*) AS row_count FROM yanki.customers
UNION ALL
SELECT 'products',                       COUNT(*) FROM yanki.products
UNION ALL
SELECT 'orders',                         COUNT(*) FROM yanki.orders
UNION ALL
SELECT 'shipping_address',               COUNT(*) FROM yanki.shipping_address
UNION ALL
SELECT 'payment_methods',                COUNT(*) FROM yanki.payment_methods
ORDER BY table_name;
-- Expected: all tables should have counts > 0
-- orders and payment_methods should both have ~1,000 rows


-- 1.2 Check for NULL primary keys — should return 0 for all
SELECT COUNT(*) AS null_customer_ids  FROM yanki.customers       WHERE customer_id IS NULL;
SELECT COUNT(*) AS null_product_ids   FROM yanki.products        WHERE product_id  IS NULL;
SELECT COUNT(*) AS null_order_ids     FROM yanki.orders          WHERE order_id    IS NULL;


-- 1.3 Check for duplicate primary keys — should return 0
SELECT customer_id, COUNT(*) FROM yanki.customers       GROUP BY customer_id HAVING COUNT(*) > 1;
SELECT product_id,  COUNT(*) FROM yanki.products        GROUP BY product_id  HAVING COUNT(*) > 1;
SELECT order_id,    COUNT(*) FROM yanki.orders          GROUP BY order_id    HAVING COUNT(*) > 1;


-- 1.4 Referential integrity check
-- Every order must have a matching customer and product
SELECT COUNT(*) AS orders_with_no_matching_customer
FROM yanki.orders o
LEFT JOIN yanki.customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- Expected: 0

SELECT COUNT(*) AS orders_with_no_matching_product
FROM yanki.orders o
LEFT JOIN yanki.products p ON o.product_id = p.product_id
WHERE p.product_id IS NULL;
-- Expected: 0


-- 1.5 Date range check — confirm data spans expected period
SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    MAX(order_date) - MIN(order_date) AS date_span_days
FROM yanki.orders;
-- Expected: 2020 → 2023


-- 1.6 Sample joined record — visual spot check
-- Verifies all tables link correctly through joins
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    p.category,
    p.brand,
    o.quantity,
    o.total_price,
    o.order_date,
    s.city,
    s.country,
    pm.payment_method,
    pm.transaction_status
FROM yanki.orders o
JOIN yanki.customers       c  ON o.customer_id  = c.customer_id
JOIN yanki.products        p  ON o.product_id   = p.product_id
JOIN yanki.shipping_address s ON o.customer_id  = s.customer_id
JOIN yanki.payment_methods pm ON o.order_id     = pm.order_id
LIMIT 5;


-- ============================================================
-- SECTION 2: BUSINESS ANALYSIS
-- Answer real questions a manager or stakeholder would ask.
-- ============================================================


-- 2.1 TOTAL REVENUE & ORDER SUMMARY (KPIs)
SELECT
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    SUM(o.quantity)                                     AS total_items_sold,
    ROUND(SUM(o.total_price)::NUMERIC, 2)               AS total_revenue,
    ROUND(AVG(o.total_price)::NUMERIC, 2)               AS avg_order_value,
    ROUND(AVG(o.quantity)::NUMERIC, 2)                  AS avg_items_per_order
FROM yanki.orders o
JOIN yanki.payment_methods pm ON o.order_id = pm.order_id
WHERE pm.transaction_status = 'completed';
-- Filter to completed transactions only for revenue accuracy


-- 2.2 REVENUE BY PRODUCT CATEGORY
SELECT
    p.category,
    COUNT(o.order_id)                                   AS total_orders,
    SUM(o.quantity)                                     AS items_sold,
    ROUND(SUM(o.total_price)::NUMERIC, 2)               AS revenue,
    ROUND(
        SUM(o.total_price) * 100.0 /
        SUM(SUM(o.total_price)) OVER ()
    , 1)                                                AS revenue_pct
FROM yanki.orders o
JOIN yanki.products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;


-- 2.3 TOP 10 BRANDS BY REVENUE
SELECT
    p.brand,
    COUNT(o.order_id)                                   AS total_orders,
    ROUND(SUM(o.total_price)::NUMERIC, 2)               AS revenue
FROM yanki.orders o
JOIN yanki.products p ON o.product_id = p.product_id
GROUP BY p.brand
ORDER BY revenue DESC
LIMIT 10;


-- 2.4 PAYMENT METHOD BREAKDOWN
SELECT
    pm.payment_method,
    COUNT(*)                                            AS total_transactions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders,
    ROUND(SUM(o.total_price)::NUMERIC, 2)               AS revenue
FROM yanki.payment_methods pm
JOIN yanki.orders o ON pm.order_id = o.order_id
GROUP BY pm.payment_method
ORDER BY total_transactions DESC;


-- 2.5 TRANSACTION STATUS BREAKDOWN
-- How many orders are completed vs pending vs failed?
SELECT
    transaction_status,
    COUNT(*)                                            AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM yanki.payment_methods
GROUP BY transaction_status
ORDER BY count DESC;


-- 2.6 REVENUE BY YEAR AND MONTH
SELECT
    EXTRACT(YEAR  FROM o.order_date)::INT               AS year,
    EXTRACT(MONTH FROM o.order_date)::INT               AS month,
    TO_CHAR(o.order_date, 'Mon')                        AS month_name,
    COUNT(o.order_id)                                   AS orders,
    ROUND(SUM(o.total_price)::NUMERIC, 2)               AS revenue
FROM yanki.orders o
JOIN yanki.payment_methods pm ON o.order_id = pm.order_id
WHERE pm.transaction_status = 'completed'
GROUP BY year, month, month_name
ORDER BY year, month;


-- 2.7 REVENUE BY YEAR (summary)
SELECT
    EXTRACT(YEAR FROM o.order_date)::INT                AS year,
    COUNT(o.order_id)                                   AS total_orders,
    ROUND(SUM(o.total_price)::NUMERIC, 2)               AS revenue
FROM yanki.orders o
JOIN yanki.payment_methods pm ON o.order_id = pm.order_id
WHERE pm.transaction_status = 'completed'
GROUP BY year
ORDER BY year;


-- 2.8 TOP 10 COUNTRIES BY REVENUE
SELECT
    s.country,
    COUNT(o.order_id)                                   AS total_orders,
    ROUND(SUM(o.total_price)::NUMERIC, 2)               AS revenue
FROM yanki.orders o
JOIN yanki.shipping_address s ON o.customer_id = s.customer_id
GROUP BY s.country
ORDER BY revenue DESC
LIMIT 10;


-- 2.9 PENDING TRANSACTIONS — REVENUE AT RISK
-- Orders that exist but have not been completed
SELECT
    COUNT(*)                                            AS pending_orders,
    ROUND(SUM(o.total_price)::NUMERIC, 2)               AS revenue_at_risk
FROM yanki.payment_methods pm
JOIN yanki.orders o ON pm.order_id = o.order_id
WHERE pm.transaction_status = 'pending';


-- 2.10 CUSTOMER ORDER FREQUENCY
-- How many customers placed more than 1 order?
SELECT
    order_count,
    COUNT(*) AS num_customers
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM yanki.orders
    GROUP BY customer_id
) sub
GROUP BY order_count
ORDER BY order_count;


-- 2.11 FULL PIPELINE SUMMARY VIEW
-- One query that gives an executive overview of the entire dataset
SELECT
    (SELECT COUNT(*)     FROM yanki.customers)                        AS total_customers,
    (SELECT COUNT(*)     FROM yanki.products)                         AS total_products,
    (SELECT COUNT(*)     FROM yanki.orders)                           AS total_orders,
    (SELECT ROUND(SUM(total_price)::NUMERIC,2) FROM yanki.orders)     AS gross_revenue,
    (SELECT COUNT(*)     FROM yanki.payment_methods
     WHERE transaction_status = 'completed')                          AS completed_orders,
    (SELECT COUNT(*)     FROM yanki.payment_methods
     WHERE transaction_status = 'pending')                            AS pending_orders,
    (SELECT COUNT(DISTINCT country) FROM yanki.shipping_address)      AS countries_served;


-- ============================================================
-- END OF FILE
-- ============================================================
