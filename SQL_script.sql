CREATE DATABASE walmart_db;
USE walmart_db;
SELECT * FROM walmart_db;
SELECT COUNT(*) FROM walmart_db;
SELECT DISTINCT payment_method FROM walmart_db;

SELECT count(DISTINCT branch) FROM walmart_db;
SELECT MAX(quantity) FROM walmart_db;

-- Business Problems
-- Q1 Find different payment methods and how many transactions and items where sold with each method
SELECT 
	payment_method,
	COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart_db
GROUP BY payment_method;

-- Q2 Idantify the higest rated category in each branch, displaying branch, category and avg rating
SELECT 
	branch, 
	category, 
    AVG(rating) as avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as ranking
FROM walmart_db
GROUP BY 1, 2;

-- Q3 Identify the busiest day for each branch based on no of transection
SELECT *
FROM (
    SELECT 
        branch, 
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS formatted_date, 
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranked
    FROM walmart_db 
    GROUP BY branch, formatted_date
) ranked_data
WHERE ranked = 1;

-- Q4 Calculate total quantities of item sold per payment method. List payment_method and total quantity
SELECT 
	payment_method, 
    sum(quantity) as total_quantity_sold 
FROM walmart_db 
GROUP BY payment_method;

-- Q5 Determine the average, minimum and maximum rating of products for each city.
-- List the city, average_rating, min_rating and max_rating.
SELECT 
	city, 
    category, 
    AVG(rating) as average_rating, 
    MIN(rating) as min_rating, 
    MAX(rating) as max_rating 
FROM walmart_db 
GROUP BY 1,2;

-- Q6 calculate total profit for each category by considering total_profit as 
-- (unit_price*quantity*profit_margin)
-- List category and total_profit, ordered from higest to lowest profit.
SELECT 
	category,
    SUM(total) as total_revenu,
    SUM(unit_price*quantity*profit_margin) as total_profit 
FROM walmart_db 
GROUP BY 1;

-- Q7 Determine most common payment method for each branch
-- Display Branch and prefered_payment_method
WITH cte 
AS (
	SELECT 
		branch, 
        payment_method, 
        COUNT(*) as total_transection, 
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranked 
	FROM walmart_db GROUP BY 1,2
    )
SELECT *
FROM cte
WHERE ranked=1;

-- Q8  Categorize sales into 3 groups MORNING, AFTERNOON, EVENING
-- Find out which of the shift has large no of invoices
SELECT branch,
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 16 THEN 'Afternoon'  -- 12 to 16 (until 16:59)
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS count
FROM walmart_db
GROUP BY branch, day_time
ORDER BY 1, 3 DESC;


-- Q9 Identify 5 branches with higest decrese ratio in 
-- revenue comaprewd to last year (current year 2023 and last year 2022)

-- 2022 SALES
WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart_db
    WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),

revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart_db
    WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)

SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cd.revenue AS current_year_revenue,
    ROUND((ls.revenue - cd.revenue)/ls.revenue*100, 2) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cd
ON ls.branch = cd.branch
WHERE 
	ls.revenue > cd.revenue
ORDER BY 4 DESC
LIMIT 5;
