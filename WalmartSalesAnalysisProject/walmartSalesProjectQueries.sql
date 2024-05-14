CREATE DATABASE IF NOT EXISTS walmartSalesProject1;
USE walmartSalesProject1;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percentage FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- ------------------------FEATURE ENGINEERING--------------------------
-- Data Cleaning 
SELECT * FROM sales;

-- Add time_of_day column
SELECT time, 
		(CASE 
			WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
            WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
            ELSE "Evening"
		END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_date VARCHAR(20);

UPDATE sales 
SET time_of_date = 
	(CASE 
			WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
            WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
            ELSE "Evening"
	END);

-- Add day_name column
SELECT date, DAYNAME(date) FROM sales;
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name = DAYNAME(date);

-- Add month_name column
SELECT date, MONTHNAME(date) FROM sales;
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales
SET month_name = MONTHNAME(date);

-- ------------------------GENERIC QUESTION--------------------------

-- Q1: How many unique cities does the data have?
SELECT DISTINCT city FROM sales;
-- Q2: In which city is each branch?
SELECT DISTINCT city, branch FROM sales;

-- ------------------------PRODUCT ANALYSIS--------------------------
-- Q1: How many unique product lines does the data have?
SELECT DISTINCT product_line FROM sales;
-- Q2: What is the most common payment method?
SELECT payment, COUNT(payment) AS most_payment_method
 FROM sales GROUP BY payment ORDER BY most_payment_method DESC;
-- Q3: What is the most selling product line?
SELECT SUM(quantity) AS productSum, product_line
FROM sales GROUP BY product_line ORDER BY productSum DESC;
-- Q4: What is the total revenue by month?
SELECT month_name AS month, SUM(total) AS total_revenue
FROM sales GROUP BY month_name ORDER BY total_revenue DESC;
-- Q5: What month had the largest COGS?
SELECT month_name AS month, SUM(cogs) AS cogs
FROM sales GROUP BY month_name ORDER BY cogs DESC LIMIT 1;
-- Q6: What product line had the largest revenue?
SELECT branch, city, SUM(total) AS total_revenue
FROM sales GROUP BY city, branch ORDER BY total_revenue DESC LIMIT 1;
-- Q7: Which city has the highest revenue?
SELECT city, SUM(total) AS total_revenue
FROM sales GROUP BY city ORDER BY total_revenue DESC LIMIT 1;
-- Q8: Which product line incurred the highest VAT?
SELECT product_line, SUM(VAT) as VAT
FROM sales GROUP BY product_line ORDER BY VAT DESC LIMIT 1; 
-- Q9: Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad',
-- based on whether its sales are above the average.
ALTER TABLE sales ADD COLUMN product_category VARCHAR(20);
UPDATE sales
JOIN (
		SELECT product_line, AVG(total) AS avg_total
		FROM sales
		GROUP BY product_line
	 )AS avg_sales ON sales.product_line = avg_sales.product_line
SET sales.product_category = CASE
                                WHEN sales.total >= avg_sales.avg_total THEN 'Good'
                                ELSE 'Bad'
                            END;
-- Q10: Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS quantity
FROM sales GROUP BY branch HAVING SUM(quantity) > AVG(quantity) ORDER BY quantity DESC;
-- Q11: What is the most common product line by gender?
SELECT gender, product_line, COUNT(gender) total_count
FROM sales GROUP BY gender, product_line ORDER BY total_count DESC;
-- Q12: What is the average rating of each product line?
SELECT product_line, AVG(rating) AS avg_rating
FROM sales GROUP BY product_line ORDER BY avg_rating DESC;

-- ------------------------SALES ANALYSIS--------------------------
-- Q1: Number of sales made in each time of the day per weekday
SELECT day_name, time_of_date, COUNT(invoice_id) AS total_sales
FROM sales WHERE day_name NOT IN ('Saturday','Sunday') GROUP BY day_name, time_of_date;
-- Q2: Identify the customer type that generates the highest revenue.
SELECT customer_type, SUM(total) AS total_sales 
FROM sales GROUP BY customer_type ORDER BY total_sales DESC;
-- Q3: Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, SUM(VAT) as sum_vat
FROM sales GROUP BY  city ORDER BY sum_vat DESC;
-- Q4: Which customer type pays the most in VAT?
SELECT customer_type, SUM(VAT) AS sum_tax
FROM sales GROUP BY customer_type ORDER BY sum_tax DESC;

-- ------------------------CUSTOMER ANALYSIS--------------------------
-- Q1: How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) AS unique_customer
FROM sales;
-- Q2: How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) AS unique_payment_methods 
FROM sales;
-- Q3: Which is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS most_common_customer
FROM sales GROUP BY customer_type ORDER BY most_common_customer DESC;
-- Q4: Which customer type buys the most?
SELECT customer_type, SUM(total) AS total_sales
FROM sales GROUP BY customer_type ORDER BY total_sales DESC;
-- Q5: What is the gender of most of the customers?
SELECT gender, COUNT(*) AS most_gender
FROM sales GROUP BY gender ORDER BY most_gender DESC LIMIT 1;
-- Q6: What is the gender distribution per branch?
SELECT branch, COUNT(gender) AS gender_distribution 
FROM sales GROUP BY branch, gender ORDER BY branch;
-- Q7: Which time of the day do customers give most ratings?
SELECT time_of_date, AVG(rating) AS avg_rating
FROM sales GROUP BY time_of_date ORDER BY avg_rating DESC LIMIT 1;
-- Q8: Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_date, AVG(rating) AS avg_rating
FROM sales GROUP BY branch, time_of_date ORDER BY avg_rating DESC;
-- Q9: Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) AS best_avg_rating 
FROM sales GROUP BY day_name ORDER BY best_avg_rating DESC;
-- Q10: Which day of the week has the best average ratings per branch?
SELECT branch, day_name, AVG(rating) AS best_avg_rating 
FROM sales GROUP BY branch, day_name ORDER BY branch, best_avg_rating DESC;

