-- SQL Retail Sales Analysis 
-- Creating Database named 'Retail_Sales_AnalysisProj'

CREATE DATABASE Retail_Sales_AnalysisProj;

--Dataset Uplaoded

SELECT * 
	FROM [dbo].[Sales _AnalysisBCKUP_data];

-- Create working table named 'RetailsalesProj'

DROP TABLE IF EXISTS RetailsalesProj;
CREATE TABLE RetailsalesProj (
	transaction_id int primary key,
	sale_date varchar (15),
	sale_time varchar (15),
	customer_id int,
	gender varchar (max)  ,
	age varchar (max),
	category varchar (max),
	quantity int,
	price_per_unit int,
	cogs varchar (max),
	total_sale int
);

SELECT * 
FROM [dbo].[RetailsalesProj];

-- Copy all from original dataset to the working table

INSERT INTO [dbo].[RetailsalesProj]
SELECT * 
	FROM [dbo].[Sales _AnalysisBCKUP_data];

SELECT TOP 10 * 
FROM [dbo].[RetailsalesProj];

-- Data Exploration

-- How many sales do we have?
SELECT COUNT(*) as total_sale FROM [dbo].[RetailsalesProj];

-- How many unique customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_customer FROM [dbo].[RetailsalesProj];

-- How many categories do we have ?
SELECT DISTINCT category FROM [dbo].[RetailsalesProj];

--Find duplicates

WITH remove_dcpt as
(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY transaction_id, sale_date, 
	sale_time, gender, category, quantity, price_per_unit,cogs, total_sale ORDER BY transaction_id) AS RowNum
FROM [dbo].[RetailsalesProj]
)
SELECT * FROM remove_dcpt 
WHERE RowNum > 1;


--Remove duplicates

WITH remove_dcpt as
(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY transaction_id, sale_date, 
	sale_time, gender, category, quantity, price_per_unit,cogs, total_sale ORDER BY transaction_id) AS RowNum
FROM [dbo].[RetailsalesProj]
)
DELETE FROM remove_dcpt 
WHERE RowNum > 1;


-- DROP NULL/BLANK VALUES

SELECT * FROM [dbo].[RetailsalesProj]
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;



DELETE FROM [dbo].[RetailsalesProj]
WHERE transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;



-- My Analysis & Findings

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT * 
FROM [dbo].[RetailsalesProj]
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022

SELECT * FROM  [dbo].[RetailsalesProj]
WHERE category = 'Clothing'
	AND
	quantity > 3
	AND
	sale_date LIKE '2022-11%';

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category, 
		SUM(total_sale) as total_sales,
		COUNT(*) AS sale_count
FROM [dbo].[RetailsalesProj]
GROUP BY category;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT STR(AVG(cast(age as numeric))) as AVG_age 
FROM [dbo].[RetailsalesProj]
WHERE category = 'Beauty';


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *
FROM [dbo].[RetailsalesProj]
WHERE total_sale > 1000


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT COUNT(*) as total_trans,
    category,
    gender
FROM [dbo].[RetailsalesProj]
GROUP 
    BY 
    category,
    gender
ORDER BY 2


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

WITH grp_CTE AS 
(
SELECT 
	YEAR (sale_date) as year,
	MONTH (sale_date) as month,
	AVG(total_sale) as avg_sale,
	RANK() OVER(PARTITION BY YEAR (sale_date) ORDER BY AVG(total_sale) DESC)  AS 'RANK'
FROM [dbo].[RetailsalesProj] 
GROUP BY sale_date
)
SELECT 
	   DISTINCT month,year, avg_sale
FROM grp_CTE
WHERE RANK = 1
order by year;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales

SELECT TOP 5
customer_id, top_sale
FROM
(
SELECT customer_id, SUM(total_sale) as top_sale 
FROM [dbo].[RetailsalesProj] 
group by customer_id
) as t1
order by 2 desc;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category, count( distinct customer_id)  as unique_customer
FROM [dbo].[RetailsalesProj]
GROUP BY category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH proj_TEMP AS 
( SELECT *,
 CASE 
WHEN DATEPART(HOUR, sale_time) <12 THEN 'Morning'
 WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
 ELSE 'Evening'
 END AS 'shift'
FROM [dbo].[RetailsalesProj]
)
select COUNT(shift) as Total_orders, shift
from proj_TEMP
 GROUP BY shift;


 --END OF THE PROJECT
