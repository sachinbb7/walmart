#What are different payment methods and how many transactions and items were sold with each methd?
SELECT payment_method, count(*) as transactions_count, ROUND(sum(unit_price* quantity),2) as items_sold
FROM clean_orders
GROUP BY 1 ;

#Which category received highest rating in each branch?
with cte1 as (SELECT branch, category, round(avg(rating),2) as highes_average_rating
FROM clean_orders
GROUP BY 1 ,2)

SELECT * FROM (
SELECT branch, category, highes_average_rating,
dense_rank()over(partition by branch order by highes_average_rating DESC) as ranker
FROM cte1) as base
WHERE ranker =1 ORDER BY 1 ASC ;


#Find busiest day of the weeek for each branch based on transaction volume
with cte1 as (SELECT branch, week(date) as week, dayname(date) as day, sum(total) as transactions_count
FROM clean_orders
GROUP BY 1,2,3) 

SELECT * 
FROM (
SELECT branch, week, day, transactions_count,
dense_rank()over(partition by branch, week order by transactions_count DESC) as ranker
FROM cte1) as base
WHERE ranker = 1 ORDER BY 1,2 ASC;


#Total quantity sold by each payment method
SELECT payment_method, sum(quantity) as total_quantity
FROM clean_orders
GROUP BY 1 ;

#Find min , max and average rating for each category in each city
SELECT city, category, min(rating) as min_rating, max(rating) as max_rating, round(avg(rating),2) as average_rating
FROM clean_orders
GROUP BY 1,2 ;

#total profit each category, list from highest to lowest
SELECT category, round(sum(profit_margin*total),2) as profit
FROM clean_orders
GROUP BY 1 ORDER BY 2 DESC;

#Most common payment method per branch
with cte1 as (SELECT branch, payment_method, count(*) as payment_frequency
FROM clean_orders
GROUP BY 1,2)

SELECT * 
FROM (
SELECT branch, payment_method, payment_frequency,
dense_rank()over(partition by branch order by payment_frequency DESC) as ranker
FROM cte1) as base
WHERE ranker = 1;

#transaction count based on sales shift throughout the day
SELECT 
CASE WHEN hour(time) >= 6 and hour(time)<12 THEN "Morning"
WHEN hour(time) >=12 AND hour(time) < 18 THEN "afternoon"
ELSE "evening" end as shift,
count(*) as transaction_count
FROM clean_orders
GROUP BY 1;

#Which branch experienced largest decrease  in revenue compared to previous year

with cte1 as (
SELECT branch, year(date) as year, round(sum(total),2) as total_revenue
FROM clean_orders
GROUP BY 1,2 ORDER BY 1,2),

cte2 as (
SELECT branch, year, total_revenue  as revenue,
lag(total_revenue,1, total_revenue)over(partition by branch order by year asc) as prev_year_revenue,
round(100.00*(total_revenue- lag(total_revenue,1, total_revenue)over(partition by branch order by year asc))/total_revenue,2) as yoy_growth
FROM cte1)

SELECT * 
FROM cte2
ORDER BY yoy_growth ASC LIMIT 1 
