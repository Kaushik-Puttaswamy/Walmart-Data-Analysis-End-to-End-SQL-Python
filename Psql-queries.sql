-- Get all records from Walmart table
SELECT * FROM walmart;

-- Count total transactions in Walmart table
SELECT COUNT(*) AS total_transactions FROM walmart;

-- Count transactions per payment method
SELECT 
    payment_method,
    COUNT(*) AS num_transactions
FROM walmart
GROUP BY payment_method;

-- Count distinct branches
SELECT COUNT(DISTINCT branch) AS total_branches FROM walmart;

-- Get minimum quantity sold
SELECT MIN(quantity) AS min_quantity FROM walmart;

-- Q1: Find different payment methods, number of transactions, and total quantity sold
SELECT 
    payment_method,
    COUNT(*) AS num_transactions,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

-- Q2: Identify the highest-rated category in each branch
WITH category_ratings AS (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
)
SELECT branch, category, avg_rating
FROM category_ratings
WHERE rank = 1;

-- Q3: Identify the busiest day for each branch based on number of transactions
WITH daily_transactions AS (
    SELECT 
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
        COUNT(*) AS num_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, day_name
)
SELECT branch, day_name, num_transactions
FROM daily_transactions
WHERE rank = 1;

-- Q4: Calculate total quantity of items sold per payment method
SELECT 
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine average, minimum, and maximum rating of each category per city
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
    SUM(total) AS total_revenue,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch
WITH preferred_payment AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method, total_transactions
FROM preferred_payment
WHERE rank = 1;

-- Q8: Categorize sales into shifts (Morning, Afternoon, Evening) and count invoices
SELECT 
    branch,
    CASE 
        WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify top 5 branches with highest revenue decrease ratio (2023 vs 2022)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)
SELECT 
    r22.branch,
    r22.revenue AS last_year_revenue,
    r23.revenue AS current_year_revenue,
    ROUND(((r22.revenue - r23.revenue) / r22.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 r22
JOIN revenue_2023 r23 ON r22.branch = r23.branch
WHERE r22.revenue > r23.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
