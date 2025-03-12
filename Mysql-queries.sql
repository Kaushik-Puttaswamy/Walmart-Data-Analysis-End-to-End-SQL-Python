-- Fetch all data from Walmart table
SELECT * FROM walmart;

-- Count total records in the dataset
SELECT COUNT(*) AS total_records FROM walmart;

-- Count payment methods and number of transactions per payment method
SELECT 
    payment_method,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY payment_method;

-- Count distinct branches
SELECT COUNT(DISTINCT branch) AS total_branches FROM walmart;

-- Find the minimum quantity sold
SELECT MIN(quantity) AS min_quantity_sold FROM walmart;

-- Business Problem Q1: Payment methods, number of transactions, and total quantity sold
SELECT 
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

-- Q2: Identify the highest-rated category in each branch
SELECT branch, category, avg_rating FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
    FROM walmart
    GROUP BY branch, category
) ranked
WHERE ranking = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
SELECT branch, day_name, transactions FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, day_name
) ranked
WHERE ranking = 1;

-- Q4: Calculate total quantity sold per payment method
SELECT 
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Average, minimum, and maximum rating of categories for each city
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q6: Calculate total profit for each category
SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Most common payment method for each branch
WITH PaymentMethodRank AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS transaction_count,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM PaymentMethodRank
WHERE ranking = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS total_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, total_invoices DESC;

-- Q9: Identify top 5 branches with highest revenue decrease from last year to current year
WITH revenue_last_year AS (
    SELECT 
        branch,
        SUM(total) AS last_year_revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = YEAR(CURDATE()) - 1
    GROUP BY branch
),
revenue_current_year AS (
    SELECT 
        branch,
        SUM(total) AS current_year_revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = YEAR(CURDATE())
    GROUP BY branch
)
SELECT 
    rly.branch,
    rly.last_year_revenue,
    rcy.current_year_revenue,
    ROUND(((rly.last_year_revenue - rcy.current_year_revenue) / rly.last_year_revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_last_year rly
JOIN revenue_current_year rcy ON rly.branch = rcy.branch
WHERE rly.last_year_revenue > rcy.current_year_revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
