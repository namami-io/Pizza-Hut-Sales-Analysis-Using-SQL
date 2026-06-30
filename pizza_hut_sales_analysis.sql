CREATE DATABASE pizzahut;
USE pizzahut;

CREATE TABLE orders(
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
primary key(order_id) 
); 

SELECT* FROM orders;


CREATE TABLE order_details (
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
primary key( order_details_id)
); 

SELECT* FROM order_details;

SELECT* FROM pizzas;
SELECT* FROM pizza_types; 


-- Basic:

--  1.Retrieve the total number of orders placed.

SELECT 
    COUNT(*) AS total_orders
FROM
    orders;
    
    
    
-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(quantity * price), 2) AS total_Revenue
FROM
    order_details AS od
        JOIN
    Pizzas ON od.pizza_id = pizzas.pizza_id;
    
    
    
    -- 3. Identify the highest-priced pizza.
 
 SELECT 
    pt.name AS pizza_name, p.price
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered 
  
SELECT 
    p.size, COUNT(od.order_details_id) AS total_orders
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC
LIMIT 1;
    
    
   --  5. List the top 5 most ordered pizza types along with their quantities
 
SELECT 
    PT.name, SUM(OD.quantity) AS QUANTITY
FROM
    pizza_types AS PT
        JOIN
    pizzas AS P ON PT.pizza_type_id = P.pizza_type_id
        JOIN
    order_details AS OD ON OD.pizza_id = P.pizza_id
GROUP BY PT.name
ORDER BY QUANTITY DESC
LIMIT 5;

-- Intermediate:

--  1.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    PT.category AS category, SUM(OD.quantity) AS total_quantity
FROM
    pizza_types AS PT
        JOIN
    pizzas AS P ON PT.pizza_type_id = P.pizza_type_id
        JOIN
    order_details AS OD ON OD.pizza_id = P.pizza_id
GROUP BY PT.category
ORDER BY total_quantity DESC;


-- 2. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.order_time) AS Hour,
    COUNT(Order_id) AS order_count
FROM
    orders
GROUP BY HOUR(orders.order_time);


-- 3.Join relevant tables to find the category-wise distribution of pizzas

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


 -- 4.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity
    
    
 -- 5.Determine the top 3 most ordered pizza types based on revenue.
 
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS total_Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_Revenue DESC
LIMIT 3;

    

-- Advanced:

 -- 1.Calculate the percentage contribution of each pizza type to total revenue.
 SELECT 
    PT.name AS pizza_type,
    ROUND(
        (SUM(OD.quantity * P.price) * 100) /
        (SELECT SUM(OD2.quantity * P2.price)
         FROM order_details AS OD2
         JOIN pizzas AS P2
             ON OD2.pizza_id = P2.pizza_id),
        2
    ) AS revenue_percentage
FROM order_details AS OD
JOIN pizzas AS P
    ON OD.pizza_id = P.pizza_id
JOIN pizza_types AS PT
    ON P.pizza_type_id = PT.pizza_type_id
GROUP BY PT.name
ORDER BY revenue_percentage DESC;


-- 2.Analyze the cumulative revenue generated over time.

 SELECT order_date ,
 SUM( revenue) OVER ( order by order_date) as cum_revenue
 FROM 
(SELECT orders.order_date ,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details JOIN
pizzas 
ON  order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY  orders.order_date) as sales;



-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name , total_Revenue
FROM 
(SELECT category,name,total_Revenue ,
RANK() OVER  ( partition by  category
order by total_Revenue ) as rn
from

(SELECT pizza_types.category,  pizza_types.name,
SUM((order_details.quantity) * pizzas.price) AS total_Revenue
FROM 
    pizza_types
        JOIN
    pizzas 
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name)  as a ) as b
WHERE rn <=3;





    
 
    
    
    
        