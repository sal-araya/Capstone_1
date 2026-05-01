-- Capstone 1 Sales Analysis
-- Student: Saliem Araya
-- Sales Manager: Erbayne Middleton
-- Territory: Northeast

USE sample_sales;

-- 1. Total revenue overall and date range
SELECT 
    SUM(total_revenue) AS total_revenue,
    MIN(start_date) AS start_date,
    MAX(end_date) AS end_date
FROM (
    SELECT SUM(ss.Sale_Amount) AS total_revenue,
           MIN(ss.Transaction_Date) AS start_date,
           MAX(ss.Transaction_Date) AS end_date
    FROM store_sales ss
    JOIN store_locations sl ON ss.Store_ID = sl.StoreId
    WHERE sl.State IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey')

    UNION ALL

    SELECT SUM(os.SalesTotal),
           MIN(os.Date),
           MAX(os.Date)
    FROM online_sales os
    WHERE os.ShiptoState IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey')
) AS northeast_sales;

-- 2. Monthly revenue breakdown
SELECT
    sales_month,
    SUM(total_revenue) AS monthly_revenue
FROM (
    SELECT DATE_FORMAT(ss.Transaction_Date, '%Y-%m') AS sales_month,
           SUM(ss.Sale_Amount) AS total_revenue
    FROM store_sales ss
    JOIN store_locations sl ON ss.Store_ID = sl.StoreId
    WHERE sl.State IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey')
    GROUP BY sales_month

    UNION ALL

    SELECT DATE_FORMAT(os.Date, '%Y-%m') AS sales_month,
           SUM(os.SalesTotal) AS total_revenue
    FROM online_sales os
    WHERE os.ShiptoState IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey')
    GROUP BY sales_month
) AS monthly
GROUP BY sales_month
ORDER BY sales_month;

-- 3. Northeast territory revenue compared to all revenue

SELECT
    'Northeast' AS territory,
    SUM(total_revenue) AS total_revenue
FROM (
    SELECT ss.Sale_Amount AS total_revenue
    FROM store_sales ss
    JOIN store_locations sl 
        ON ss.Store_ID = sl.StoreId
    WHERE sl.State IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey')


    UNION

    SELECT os.SalesTotal AS total_revenue
    FROM online_sales os
    WHERE os.ShiptoState IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey'

    )
) AS northeast

UNION ALL

SELECT
    'All Regions' AS territory,
    SUM(total_revenue) AS total_revenue
FROM (
    SELECT Sale_Amount AS total_revenue FROM store_sales
    UNION ALL
    SELECT SalesTotal AS total_revenue FROM online_sales
) AS all_sales;


-- 4. Transactions and average transaction size
SELECT
    sales_month,
    COUNT(*) AS number_of_transactions,
    AVG(transaction_amount) AS avg_transaction_size
FROM (
    SELECT DATE_FORMAT(ss.Transaction_Date, '%Y-%m') AS sales_month,
           ss.Sale_Amount AS transaction_amount
    FROM store_sales ss
    JOIN store_locations sl ON ss.Store_ID = sl.StoreId
    WHERE sl.State IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey')

    UNION ALL

    SELECT DATE_FORMAT(os.Date, '%Y-%m') AS sales_month,
           os.SalesTotal AS transaction_amount
    FROM online_sales os
    WHERE os.ShiptoState IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey')
) AS transactions
GROUP BY sales_month
ORDER BY sales_month;

-- 5. Store Ranking
SELECT 
   sl.StoreLocation,
   sl.State,
   SUM(ss.Sale_Amount) AS total_revenue,
   RANK() OVER(ORDER BY SUM(ss.Sale_Amount) DESC) AS store_rank 
FROM store_sales ss
JOIN store_locations sl
   ON ss.Store_ID = sl.StoreId
WHERE sl.State IN ('Massachusetts', 'Maine', 'Maryland', 'New Jersey')
GROUP BY sl.StoreLocation, sl.State
ORDER BY store_rank;


-- Question 6: Recommendation

-- The analysis of the Northeast territory, I recommend focusing sales
-- on the highest-performing stores and states, as they generate the most revenue 
-- have the strongest growth potenial. 

-- The monthly revenue trends show that certain months consistently perform better,
-- so increasing marketing and promotions during those peak periods could further boost sales.

-- Additionally, stores with lower performance should be evaluated to identify potential
-- issues such as low customer traffic, product mix, or staffing. Improving these areas
-- could increase overall revenue.

-- I also recommend focusing on product categories with higher average transaction sizes,
-- as they contribute more revenue per sale and offer a strong opportunity for growth
-- in the next quarter.