---Database Queries Related to the Transaction Table----
SELECT *
FROM transaction;

---Total number of customers---
SELECT COUNT(DISTINCT customer_id) as num_customers
FROM transaction;

--- Total customers in December---
SELECT COUNT(DISTINCT customer_id) 
FROM(
SELECT customer_id, DATE_PART('month', transaction_date) month_date 
FROM transaction 
WHERE DATE_PART('month', transaction_date) = 12) t1

---Total spend---
SELECT FLOOR(SUM(list_price)) total_spend
FROM transaction;

-- Total spend in December---
SELECT SUM(list_price) 
FROM(
SELECT list_price, DATE_PART('month', transaction_date) month_date 
FROM transaction
WHERE DATE_PART('month', transaction_date) = 12) t1

--- 4 month customer trend ---
SELECT COUNT(DISTINCT customer_id), DATE_PART('month', transaction_date) month_date 
FROM transaction
WHERE DATE_PART('month', transaction_date) = 8 OR 
DATE_PART('month', transaction_date) = 9 OR 
DATE_PART('month', transaction_date) = 10 OR 
DATE_PART('month', transaction_date) = 11 OR 
DATE_PART('month', transaction_date) = 12 
GROUP BY DATE_PART('month', transaction_date) 

---Running total of the customers for each month---
SELECT DATE_PART('month', transaction_date), 
COUNT(customer_id) OVER (PARTITION BY DATE_PART('month', transaction_date) ORDER BY DATE_PART('month', transaction_date))
FROM transaction;

---4 month total spend---
SELECT SUM(list_price), DATE_PART('month', transaction_date) month_date 
FROM transaction
WHERE DATE_PART('month', transaction_date) = 8 OR 
DATE_PART('month', transaction_date) = 9 OR 
DATE_PART('month', transaction_date) = 10 OR 
DATE_PART('month', transaction_date) = 11 OR 
DATE_PART('month', transaction_date) = 12 
GROUP BY DATE_PART('month', transaction_date) 
ORDER BY month_date;

---Running total of the spend for each month
SELECT DATE_PART('month', transaction_date), 
SUM(list_price) OVER (PARTITION BY DATE_PART('month', transaction_date) ORDER BY DATE_PART('month', transaction_date))
FROM transaction;

---Top 10 Goods Sold---
SELECT CONCAT(brand,':',' ',product_line,':',' ','class:',' ',product_class) products,
COUNT(transaction_id) quantity_sold
FROM transaction
GROUP BY products
ORDER BY quantity_sold DESC
LIMIT 10;

--- Total number of females who made transactions---
SELECT COUNT(DISTINCT t.customer_id) num_customers, 
g.gender
FROM transaction t
JOIN customer_demographic g
ON t.customer_id = g.customer_id
WHERE g.gender = 'Female'
GROUP BY g.gender;

---- How many females were there for each age
SELECT COUNT(t.customer_id) num_female_customers, 
ABS(EXTRACT(year FROM AGE(current_date,g.dob))) female_age
FROM customer_demographic g
JOIN transaction t
ON t.customer_id = g.customer_id
WHERE g.gender = 'Female'
GROUP BY ABS(EXTRACT(year FROM AGE(current_date,g.dob)))
ORDER BY num_female_customers DESC;

--Running total of number of females per age---
SELECT ABS(EXTRACT(year FROM AGE(current_date,g.dob))) female_age, 
COUNT(t.customer_id) OVER (PARTITION BY ABS(EXTRACT(year FROM AGE(current_date,g.dob))))
FROM customer_demographic g
JOIN transaction t
ON t.customer_id = g.customer_id
WHERE g.gender = 'Female';

--- Total number of males who made transactions---
SELECT COUNT(DISTINCT t.customer_id) num_customers, 
g.gender
FROM transaction t
JOIN customer_demographic g
ON t.customer_id = g.customer_id
WHERE g.gender = 'Male'
GROUP BY g.gender;

---- How many males were there for each age----
SELECT COUNT(t.customer_id) num_female_customers, 
ABS(EXTRACT(year FROM AGE(current_date,g.dob))) female_age
FROM customer_demographic g
JOIN transaction t
ON t.customer_id = g.customer_id
WHERE g.gender = 'Male'
GROUP BY ABS(EXTRACT(year FROM AGE(current_date,g.dob)))
ORDER BY num_female_customers DESC;

--Running total of number of males per age---
SELECT ABS(EXTRACT(year FROM AGE(current_date,g.dob))) female_age, 
COUNT(t.customer_id) OVER (PARTITION BY ABS(EXTRACT(year FROM AGE(current_date,g.dob))))
FROM customer_demographic g
JOIN transaction t
ON t.customer_id = g.customer_id
WHERE g.gender = 'Male';

--- Whether customers preferred to order online or in person---
SELECT online_order, COUNT(customer_id)
FROM transaction
GROUP BY online_order;

--- The average cost of each product---
SELECT CONCAT(brand,':',' ',product_line,':',' ','class:',' ',product_class) products,
ROUND(AVG(standard_cost),2) avg_cost
FROM transaction
GROUP BY products
ORDER BY avg_cost DESC;

--- Profit for each product sold---
SELECT CONCAT(brand,':',' ',product_line,':',' ','class:',' ',product_class) products,
(list_price-standard_cost) profit
FROM transaction
ORDER BY profit DESC;

---Number of approved orders---
SELECT t1.order_status, COUNT(t1.status_count) new_status_count
FROM(
SELECT order_status, CASE WHEN order_status = 'Approved' THEN 1 ELSE 0 END AS status_count
FROM transaction) t1
GROUP BY t1.order_status;