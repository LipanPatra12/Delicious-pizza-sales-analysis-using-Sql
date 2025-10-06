create database pizzas;
use pizzas;


select* from orders;
select* from pizza_types;
select* from order_details;
select* from pizzaa;

-- Basic-:
--Retrieve the total number of orders placed.

select count(order_id)as total_order from orders;

--Calculate the total revenue generated from pizza sales.

select  sum(order_details.quantity * pizzaa.price) as total_sales
from order_details
join pizzaa
on order_details.pizza_id= pizzaa.pizza_id;

--Identify the highest-priced pizza.

select pizzaa.price,pizza_types.name  
from pizzaa 
join pizza_types
on pizzaa.pizza_type_id=pizza_types.pizza_type_id
order by price desc;

--or

SELECT p.price, pt.name
FROM pizzaa p
JOIN pizza_types pt
  ON p.pizza_type_id = pt.pizza_type_id
WHERE p.price = (SELECT MAX(price) FROM pizzaa);


--Identify the most common pizza quantity ordered.
select quantity ,count(order_details_id) as total_number
from order_details
group by quantity
order by total_number desc;

--identify the most common pizza size ordered

SELECT p.size, COUNT(od.order_details_id) AS total_orders
FROM order_details od
JOIN pizzaa p
  ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC;


--List the top 5 most ordered pizza types along with their quantities.

select top 5 t.name,sum(od.quantity)as total_quantity
from pizzaa a
join pizza_types t
on t.pizza_type_id=a.pizza_type_id
join order_details od
on od.pizza_id=a.pizza_id
group by t.name 
order by total_quantity desc ;


--Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.

select* from orders;
select* from pizza_types;
select* from order_details;
select* from pizzaa;

select  t.category,sum(od.quantity)as total_quantity
from pizzaa a
join pizza_types t
on t.pizza_type_id=a.pizza_type_id
join order_details od
on od.pizza_id=a.pizza_id
group by t.category 
order by total_quantity desc ;

--Determine the distribution of orders by hour of the day.

SELECT DATEPART(HOUR, time) AS order_hour,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY DATEPART(HOUR, time)
ORDER BY order_hour desc;

--Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) as total_type_of_piza
from pizza_types
group by category;



--Group the orders by date and calculate the average number of pizzas ordered per day.

WITH DailyTotals AS (
    SELECT o.date, SUM(od.quantity) AS total_pizzas
    FROM orders o
    JOIN order_details od 
      ON o.order_id = od.order_id
    GROUP BY o.date
)
SELECT AVG(total_pizzas) AS avg_pizzas_per_day
FROM DailyTotals;


--Determine the top 3 most ordered pizza types based on revenue.

select top 3 p.pizza_id,sum(p.price*od.quantity)as total
from order_details od
join pizzaa p
on od.pizza_id= p.pizza_id
group by p.pizza_id
order by total desc;


--Advanced-:
--Calculate the percentage contribution of each category to total revenue.

select t.category,(sum(p.price*od.quantity) /
(select  sum(order_details.quantity * pizzaa.price) as total_sales
from order_details
join pizzaa
on order_details.pizza_id= pizzaa.pizza_id))*100 as revenue
from pizza_types t
join pizzaa p
on t.pizza_type_id=p.pizza_type_id
join order_details od 
on od.pizza_id=p.pizza_id
group by t.category
order by revenue desc;

--Analyze the cumulative revenue generated over time.

SELECT 
    date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY date) AS cumulative_revenue
FROM (
    SELECT 
        o.date,
        SUM(p.price * od.quantity) AS daily_revenue
    FROM orders o
    JOIN order_details od 
        ON o.order_id = od.order_id
    JOIN pizzaa p 
        ON od.pizza_id = p.pizza_id
    GROUP BY o.date
) AS daily
ORDER BY date;


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,pizza_type_id,daily_revenue,rank_c

from
	(select SUM(p.price * od.quantity) AS daily_revenue,t.category,t.pizza_type_id,
	rank() over(PARTITION BY category ORDER BY SUM(p.price * od.quantity)DESC) as rank_c
from pizzaa p
join order_details od
on p.pizza_id=od.pizza_id
join pizza_types t
on t.pizza_type_id=p.pizza_type_id
group by t.category,t.pizza_type_id
)as ab
where rank_c <=3
order by category, rank_c asc;




