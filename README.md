# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Junior Data Analyst  
**Database**: `Retail_Sales_AnalysisProj`

This project was designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data using MS-SQL. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.
5. **Create alternative Table**: Create a new table for manipulating sales data and keep original dataset as backup.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `Retail_Sales_AnalysisProj`.
- **Table Creation**: A table named `RetailsalesProj` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold ( as 'cogs'), and total sale amount.

```sql
CREATE DATABASE Retail_Sales_AnalysisProj;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Remove Duplictates**: Find and delete duplictates records in the dataset.
- **Dropping Null/Blank Value**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM [dbo].[RetailsalesProj];
SELECT COUNT(DISTINCT customer_id) FROM [dbo].[RetailsalesProj];
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
```

### 3.My Data Analysis & Business Key Problems & Answers

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05'**:
```sql
SELECT * 
FROM [dbo].[RetailsalesProj]
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022**:
```sql
SELECT * FROM  [dbo].[RetailsalesProj]
WHERE category = 'Clothing'
	AND
	quantity > 3
	AND
	sale_date LIKE '2022-11%';
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT category, 
		SUM(total_sale) as total_sales,
		COUNT(*) AS sale_count
FROM [dbo].[RetailsalesProj]
GROUP BY category;
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category**:
```sql
SELECT STR(AVG(cast(age as numeric))) as AVG_age 
FROM [dbo].[RetailsalesProj]
WHERE category = 'Beauty';
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT *
FROM [dbo].[RetailsalesProj]
WHERE total_sale > 1000

```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT COUNT(*) as total_trans,
    category,
    gender
FROM [dbo].[RetailsalesProj]
GROUP 
    BY 
    category,
    gender
ORDER BY 2
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
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
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
SELECT TOP 5
customer_id, top_sale
FROM
(
SELECT customer_id, SUM(total_sale) as top_sale 
FROM [dbo].[RetailsalesProj] 
group by customer_id
) as t1
order by 2 desc;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT category, count( distinct customer_id)  as unique_customer
FROM [dbo].[RetailsalesProj]
GROUP BY category;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons and shift analysis shows there's more sales during evening shift.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as my introduction to SQL as junior data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## Author - A.O ADENUGA

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

For more content on SQL, data analysis, and other data-related topics, you can reach me on social media below:

- **E-mail**: DenugaTechEmpire@outlook.com
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/a-o-adenuga-17a4762b7?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app)

Thank you for your support, and I look forward to connecting with you!
