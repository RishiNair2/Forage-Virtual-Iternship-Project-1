---New customer list database queries ---
SELECT *
FROM new_customer_list;

--- The state in Australia that made the most bike_related_purchases in the past 3 years---
SELECT state, SUM(past_3_years_bike_related_purchases) total_bike_related_purchases
FROM new_customer_list
GROUP BY state
ORDER BY total_bike_related_purchases DESC;

--- Target Customers---
SELECT CONCAT(first_name|| ' '||last_name) full_name,job_title, postcode, state, 
rank model_rank
FROM new_customer_list;

---- Age groups which made the most bike realted purchases---
WITH t1 AS (
SELECT EXTRACT('year' from AGE(current_date, dob)) birth_year , 
	past_3_years_bike_related_purchases total_bike_related_purchases
FROM new_customer_list 
	)

SELECT CASE WHEN t1.birth_year < 20 THEN '<20' 
WHEN t1.birth_year BETWEEN 20 AND 29 THEN '20-29'
WHEN t1.birth_year BETWEEN 30 AND 39 THEN '30-39'
WHEN t1.birth_year BETWEEN 40 AND 49 THEN '40-49'
WHEN t1.birth_year BETWEEN 50 AND 59 THEN '50-59'
WHEN t1.birth_year BETWEEN 60 AND 69 THEN '60-69'
WHEN t1.birth_year BETWEEN 70 AND 79 THEN '70-79'
WHEN t1.birth_year >80 THEN '80+' END AS age_group,
SUM (t1.total_bike_related_purchases) total_bike_related_purchases
FROM t1
Group BY 1
ORDER BY 2 DESC;


---Creating a table to find future sales data---
CREATE TEMPORARY TABLE customer_data(
gender text,
past_3_years_bike_related_purchases numeric,
dob date,
state text,
customer_id text,
transaction_id text,
transaction_date date,
online_order boolean,
brand text,
product_line text,
product_class text,
product_size text,
list_price numeric,
standard_cost numeric)

insert into customer_data
select n.gender, n.past_3_years_bike_related_purchases, n.dob, n.state,
t.customer_id,t.transaction_id,t.transaction_date,t.online_order,t.brand,t.product_line,
t.product_class,t.product_size,t.list_price,t.standard_cost
FROM transaction t
JOIN customer_demographic d
ON t.customer_id = d.customer_id
JOIN new_customer_list n
ON n.gender = d.gender;

--- From the customer_data temp table--
SELECT *
FROM customer_data;

--- Who could possibly make the most transactions online between men and women based on previous data---
SELECT gender, COUNT(transaction_id) num_transactions
FROM customer_data
WHERE online_order = 'true'
GROUP BY gender;

--- Who could possibly make the most transactions in store between men and women based on previous data--
SELECT gender, COUNT(transaction_id) num_transactions
FROM customer_data
WHERE online_order = 'false'
GROUP BY gender;

--- In which product could potentially have the most purchases---
SELECT SUM(past_3_years_bike_related_purchases) total_bike_related_purchase,
CONCAT(brand||' '||product_line||' '||product_class||' '||product_size) product_name
FROM customer_data
GROUP BY product_name
ORDER BY total_bike_related_purchase DESC;

--- Potential number of customers by age group---
SELECT CASE WHEN t2.birth_year < 20 THEN '<20' 
WHEN t2.birth_year BETWEEN 20 AND 29 THEN '20-29'
WHEN t2.birth_year BETWEEN 30 AND 39 THEN '30-39'
WHEN t2.birth_year BETWEEN 40 AND 49 THEN '40-49'
WHEN t2.birth_year BETWEEN 50 AND 59 THEN '50-59'
WHEN t2.birth_year BETWEEN 60 AND 69 THEN '60-69'
WHEN t2.birth_year BETWEEN 70 AND 79 THEN '70-79'
WHEN t2.birth_year >80 THEN '80+' END AS age_group,
COUNT(t2.num_customers)
FROM(
SELECT EXTRACT('year' from AGE(current_date, dob)) birth_year, 
customer_id AS num_customers
FROM customer_data
) t2
GROUP BY 1
ORDER BY 2 DESC;

--Which Australian state could have the most transactions---
SELECT state, COUNT(transaction_id) num_transactions
FROM customer_data
GROUP BY state
ORDER BY num_transactions DESC;

-- Potential average money spent per each age group---
SELECT CASE WHEN t2.birth_year < 20 THEN '<20' 
WHEN t2.birth_year BETWEEN 20 AND 29 THEN '20-29'
WHEN t2.birth_year BETWEEN 30 AND 39 THEN '30-39'
WHEN t2.birth_year BETWEEN 40 AND 49 THEN '40-49'
WHEN t2.birth_year BETWEEN 50 AND 59 THEN '50-59'
WHEN t2.birth_year BETWEEN 60 AND 69 THEN '60-69'
WHEN t2.birth_year BETWEEN 70 AND 79 THEN '70-79'
WHEN t2.birth_year >80 THEN '80+' END AS age_group,
ROUND(AVG(t2.list_price),2) avg_spent
FROM(
SELECT EXTRACT('year' from AGE(current_date, dob)) birth_year, list_price
FROM customer_data
) t2
GROUP BY 1
ORDER BY avg_spent DESC;

-- The total number of people who owned a car and made bike related purchases---
SELECT owns_car, SUM(past_3_years_bike_related_purchases) total_bike_related_purchases
FROM new_customer_list
GROUP BY owns_car
ORDER BY total_bike_related_purchases DESC;

--- The gender, job_title, job_industry, wealth_segment that made the most bike_related purchases in the past 3 years---
SELECT gender, SUM(past_3_years_bike_related_purchases) total_bike_related_purchases
FROM new_customer_list
GROUP BY gender
ORDER BY total_bike_related_purchases DESC;

SELECT job_title, SUM(past_3_years_bike_related_purchases) total_bike_related_purchases
FROM new_customer_list
GROUP BY job_title
ORDER BY total_bike_related_purchases DESC;

SELECT wealth_segment, SUM(past_3_years_bike_related_purchases) total_bike_related_purchases
FROM new_customer_list
GROUP BY wealth_segment
ORDER BY total_bike_related_purchases DESC;

SELECT job_industry_category job_category, SUM(past_3_years_bike_related_purchases) total_bike_related_purchases
FROM new_customer_list
GROUP BY job_category
ORDER BY total_bike_related_purchases DESC;







