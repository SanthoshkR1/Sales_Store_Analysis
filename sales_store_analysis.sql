create database sales ;
use sales;

select * from sales_store_updated_allign_with_video;

SHOW TABLES;

DESCRIBE sales_store;

RENAME TABLE sales_store_updated_allign_with_video TO sales_store;
SELECT * FROM sales_store LIMIT 10;

CREATE TABLE sales AS
SELECT * FROM sales_store;

select * from sales store;

DESCRIBE sales_store;

SELECT purchase_date
FROM sales_store
LIMIT 10;

select * from sales_store;

UPDATE sales_store
SET purchase_date = STR_TO_DATE(purchase_date, '%d-%m-%Y');

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_store
SET purchase_date = STR_TO_DATE(purchase_date, '%d-%m-%Y');

SELECT purchase_date
FROM sales_store
WHERE purchase_date LIKE '%/%'
LIMIT 10;

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_store
SET purchase_date =
    CASE
        WHEN purchase_date LIKE '%/%'
        THEN STR_TO_DATE(purchase_date, '%d/%m/%Y')
        ELSE STR_TO_DATE(purchase_date, '%d-%m-%Y')
    END;

SET SQL_SAFE_UPDATES = 1;

SELECT purchase_date
FROM sales_store
LIMIT 10;

ALTER TABLE sales_store
MODIFY purchase_date DATE;

SELECT COUNT(*) AS invalid_rows
FROM sales_store
WHERE STR_TO_DATE(purchase_date, '%Y-%m-%d') IS NULL;

---------------------
-- Data cleaning
----------------------

select * from sales_store;

select CUSTOMER_NAME from sales_store;

CREATE TABLE sales AS
SELECT *
FROM sales_store;

select * from sales;

-- Step 2 :- Correction of Headers
ALTER TABLE sales_store CHANGE quantiy quantity INT;
ALTER TABLE sales_store CHANGE prce price DECIMAL(10,2);

-- Data Cleaning
-- step 1 - to check for duplicate
SELECT transaction_id, COUNT(*) AS cnt
FROM sales
GROUP BY transaction_id
HAVING cnt > 1;

-- TXN855235
-- TXN342128
-- TXN240646
-- TXN981773

WITH CTE AS (
    SELECT 
        transaction_id,
        customer_id,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id 
            ORDER BY customer_id
        ) AS rn
    FROM sales
)
DELETE s
FROM sales s
JOIN CTE c
ON s.transaction_id = c.transaction_id
AND s.customer_id = c.customer_id
WHERE c.rn > 1;

SELECT transaction_id, COUNT(*)
FROM sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM sales
HAVING COUNT(*) > 1;


select * from CTE
where transaction_id IN ('TXN855235','TXN342128','TXN240646','TXN981773');

select * from sales;
SET SQL_SAFE_UPDATES = 0;

-- STEP 3: CHECK DATA TYPES
DESCRIBE sales;


-- Step 4 :- To Check Null Values 
-- to check null count

SELECT *
FROM sales
WHERE transaction_id IS NULL
   OR customer_id IS NULL
   OR customer_name IS NULL
   OR customer_age IS NULL
   OR gender IS NULL
   OR product_id IS NULL
   OR product_name IS NULL
   OR product_category IS NULL
   OR quantiy IS NULL
   OR prce IS NULL
   OR payment_mode IS NULL
   OR purchase_date IS NULL
   OR status IS NULL;
   
   delete from sales where transaction_id IS NULL;
   
   select * from sales;
   
   create database saless;
   use saless;

-- Data Analysis--
-- 1. What are the top 5 most selling products by quantity?

SELECT product_name, SUM(quantity) AS total_quantity_sold
FROM sales
WHERE status = 'delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- Business Problem: We don't know which products are most in demand.
-- Business Impact: Helps prioritize stock and boost sales through targeted promotions.

-- 2 Which products are most frequently cancelled?
SELECT product_name, COUNT(*) AS total_cancelled
FROM sales
WHERE status='cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC
LIMIT 5;

-- Business Problem: Frequent cancellations affect revenue and customer trust.
-- Business Impact: Identify poor-performing products to improve quality or remove from catalog.

-- 3  What time of the day has the highest number of purchases?
SELECT 
    CASE 
        WHEN HOUR(time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
        WHEN HOUR(time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN HOUR(time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS time_of_day,
    COUNT(*) AS total_orders
FROM sales
GROUP BY time_of_day
ORDER BY total_orders DESC;

-- Business Problem Solved: Find peak sales times.
-- Business Impact: Optimize staffing, promotions, and server loads.


-- 4. Who are the top 5 highest spending customers?
SELECT customer_name,
       FORMAT(SUM(price*quantity),0) AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM(price*quantity) DESC
LIMIT 5;

-- Business Problem Solved: Identify VIP customers.
-- Business Impact: Personalized offers, loyalty rewards, and retention.



-- 5. Which product categories generate the highest revenue?
SELECT product_category,
       FORMAT(SUM(price*quantity),0) AS revenue
FROM sales
GROUP BY product_category
ORDER BY SUM(price*quantity) DESC;

-- Business Problem Solved: Identify top-performing product categories.

-- Business Impact: Refine product strategy, supply chain, and promotions.
-- allowing the business to invest more in high-margin or high-demand categories.


-- 6. What is the return/cancellation rate per product category?
-- cancellation
SELECT product_category,
       ROUND(SUM(status='cancelled')*100/COUNT(*),2) AS cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY cancelled_percent DESC;

-- Return
SELECT product_category,
       ROUND(SUM(status='returned')*100/COUNT(*),2) AS returned_percent
FROM sales
GROUP BY product_category
ORDER BY returned_percent DESC;

-- Business Problem Solved: Monitor dissatisfaction trends per category.

-- Business Impact: Reduce returns, improve product descriptions/expectations.
-- Helps identify and fix product or logistics issues.


-- 7. What is the most preferred payment mode?
SELECT payment_mode, COUNT(*) AS total_count
FROM sales
GROUP BY payment_mode
ORDER BY total_count DESC;

-- Business Problem Solved: Know which payment options customers prefer.
-- Business Impact: Streamline payment processing, prioritize popular modes.


-- 8  How does age group affect purchasing behavior?
SELECT 
    CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS age_group,
    FORMAT(SUM(price*quantity),0) AS total_purchase
FROM sales
GROUP BY age_group
ORDER BY SUM(price*quantity) DESC;

-- Business Problem Solved: Understand customer demographics.
-- Business Impact: Targeted marketing and product recommendations by age group.


-- 9 What’s the monthly sales trend?
SELECT 
    CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS age_group,
    FORMAT(SUM(price*quantity),0) AS total_purchase
FROM sales
GROUP BY age_group
ORDER BY SUM(price*quantity) DESC;

SELECT 
    MONTH(purchase_date) AS month,
    FORMAT(SUM(price*quantity),0) AS total_sales
FROM sales
GROUP BY month
ORDER BY month;

-- Business Problem: Sales fluctuations go unnoticed.
-- Business Impact: Plan inventory and marketing according to seasonal trends.

-- 
-- 10  Are certain genders buying more specific product categories?
SELECT product_category,
       SUM(CASE WHEN gender='M' THEN 1 ELSE 0 END) AS Male,
       SUM(CASE WHEN gender='F' THEN 1 ELSE 0 END) AS Female
FROM sales
GROUP BY product_category
ORDER BY product_category;

-- Business Problem Solved: Gender-based product preferences.
-- Business Impact: Personalized ads, gender-focused campaigns.

