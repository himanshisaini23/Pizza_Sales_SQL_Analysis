CREATE DATABASE Pizza_hut;

CREATE TABLE orders (
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY(order_id) );

CREATE TABLE order_details (
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id) );

-- 1. Retrieve the total number of orders placed.
SELECT count(order_id) AS total_orders FROM orders;
SELECT count(*) FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT round(sum(quantity * price),2) as total_revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id;

-- 3. Identitfy the highest-priced pizza.
SELECT pt.name, p.price
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;
-- or
SELECT pt.name, p.price
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
WHERE price = (SELECT max(price) FROM pizzas);

-- 4. Identify the most common pizza size ordered.
SELECT size, count(order_details_id) as most_common
FROM pizzas p
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY most_common DESC LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities
SELECT name, sum(quantity) as quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY name 
ORDER BY quantity DESC LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT category, sum(quantity) as quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY category  
ORDER BY quantity DESC;

-- 7. Determine the distribution of orders by hour of the day.
SELECT hour(order_time) as hour, count(*) as order_count 
FROM orders
GROUP BY hour;

-- 8. Join tables to find category-wise distribution of pizzas.
SELECT category, count(name)
FROM pizza_types
GROUP BY category;

-- 9.Group orders by date and calculate avg no. of pizzas ordered per day
SELECT round(avg(quantity),0) as avg_pizza_perday FROM
(SELECT order_date, sum(quantity) as quantity
FROM orders o JOIN order_details od
ON o.order_id = od.order_id
GROUP BY order_date) as order_quantity;

-- 10.Find top 3 most ordered pizza types based on revenue.
SELECT name, sum(quantity * price) as revenue
FROM pizza_types pt 
JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY name 
ORDER BY revenue desc limit 3;

-- 11. Calculate  % contribution of each pizza type to total revenue
SELECT category, round(sum(quantity * price) / (SELECT 
round(sum(quantity * price),2)as total_sales 
FROM order_details od
Join pizzas p on p.pizza_id = od.pizza_id ) * 100 ,2) as revenue
FROM pizza_types pt 
JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY category 
ORDER BY revenue desc;

-- 12.analyze cumulative revenue generated over time.
SELECT order_date, 
sum(revenue) over (order by order_date) as cum_revenue
from
(SELECT order_date, sum(quantity * price) as revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY order_date ) as sales;

-- 13.Find top 3 most ordered pizza types based on revenue fro each pizza category.
SELECT category, name , revenue from
(SELECT category, name , revenue ,
rank() over(partition by category order by revenue desc) as rn
from
(SELECT category, name, sum(quantity*price) as revenue
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY  category, name) as a)as b
WHERE rn<= 3;


