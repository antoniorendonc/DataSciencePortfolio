/*
8 Week SQL Challenge
Case Study #2 - Pizza Runner
https://8weeksqlchallenge.com/case-study-1/

Antonio Rendon
*/


CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');




-- A. Pizza Metrics

-- How many pizzas were ordered?
SELECT COUNT(order_id) AS total_orders
FROM customer_orders

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) AS unique_customer_orders
FROM customer_orders

-- How many successful orders were delivered by each runner?
SELECT runner_id ,
		COUNT(DISTINCT order_id) 
FROM runner_orders
WHERE pickup_time !='null'
GROUP BY runner_id

-- How many of each type of pizza was delivered?
SELECT PN.pizza_name , 
	COUNT(CO.order_id) AS delivered
FROM runner_orders AS RO
INNER JOIN customer_orders AS CO ON RO.order_id = CO.order_id
INNER JOIN pizza_names AS PN ON CO.pizza_id = PN.pizza_id
WHERE RO.pickup_time !='null'
GROUP BY PN.pizza_name

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT PN.pizza_name , 
		CO.customer_id,
	COUNT(CO.order_id) AS ordered
FROM customer_orders AS CO
INNER JOIN pizza_names AS PN ON CO.pizza_id = PN.pizza_id
GROUP BY CO.customer_id, PN.pizza_name
ORDER BY CO.customer_id

-- What was the maximum number of pizzas delivered in a single order?

SELECT COUNT(CO.pizza_id) AS num_orders
FROM customer_orders AS CO
INNER JOIN runner_orders AS RO ON CO.order_id = RO.order_id
WHERE RO.pickup_time !='null'
GROUP BY CO.order_id
ORDER BY num_orders DESC
LIMIT 1

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 	customer_id,
		SUM(CASE
			WHEN(
				(LENGTH(CO.exclusions) >0 AND CO.exclusions <>'null') 
				OR 
				(LENGTH(CO.extras) >0 AND CO.extras <>'null' AND extras IS NOT NULL)
				)  = TRUE 
			THEN 1 
			ELSE 0
			END ) AS has_changes,		
		SUM(CASE
			WHEN(
				(LENGTH(CO.exclusions) >0 AND CO.exclusions <>'null') 
				OR 
				(LENGTH(CO.extras) >0 AND CO.extras <>'null' AND extras IS NOT NULL)
				)  = TRUE 
			THEN 0 
			ELSE 1
			END ) AS no_changes
FROM customer_orders AS CO
INNER JOIN runner_orders AS RO ON CO.order_id = RO.order_id
WHERE RO.pickup_time !='null'
GROUP BY 1
ORDER BY customer_id

-- How many pizzas were delivered that had both exclusions and extras?
SELECT 	COUNT(CO.order_id)	AS delivered_pizzas_with_extras_and_exclusions		
FROM customer_orders AS CO
INNER JOIN runner_orders AS RO ON CO.order_id = RO.order_id
WHERE RO.pickup_time !='null' AND
		(LENGTH(CO.exclusions) >0 AND CO.exclusions <>'null')
				AND
			(LENGTH(CO.extras) >0 AND CO.extras <>'null') = TRUE

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT  EXTRACT(hour FROM order_time) AS hour_day,
		COUNT(order_id) AS orders
FROM customer_orders
GROUP BY 1
ORDER BY 1

-- What was the volume of orders for each day of the week?
SELECT  EXTRACT(DOW FROM order_time) AS day_week,
		TO_CHAR (order_time, 'Day'),
		COUNT(order_id)  AS orders
FROM customer_orders
GROUP BY 1,2
ORDER BY 1,2

--B. Runner and Customer Experience
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 	date_trunc('week', registration_date) AS week ,
		count(runner_id) AS runners
FROM runners
GROUP BY 1

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
	RO.runner_id,
	ROUND(AVG(
		EXTRACT(MINUTE FROM CAST(RO.pickup_time AS TIMESTAMP) - CO.order_time)
		),2) AS avg_time
FROM runner_orders AS RO
		INNER JOIN customer_orders AS CO ON CO.order_id = RO.order_id
WHERE 	pickup_time <> 'null'
GROUP BY 	RO.runner_id
--Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH CTE AS (	SELECT CO.order_id, 
						COUNT(CO.pizza_id) AS no_pizzas,
						MAX(EXTRACT(MINUTE FROM CAST(RO.pickup_time AS TIMESTAMP) - CO.order_time))
						AS time
				FROM runner_orders AS RO
							INNER JOIN customer_orders AS CO ON CO.order_id = RO.order_id
				WHERE 	RO.pickup_time <> 'null'
				GROUP BY CO.order_id
				)
SELECT no_pizzas, ROUND(AVG(time))
FROM CTE
GROUP BY no_pizzas

--What was the average distance travelled for each customer?
SELECT CO.customer_id, 
	ROUND(AVG(CAST(REPLACE(RO.distance,'km','') AS NUMERIC)),2) AS avg_distance
FROM runner_orders AS RO
INNER JOIN customer_orders AS CO ON RO.order_id = CO.order_id
WHERE distance <>'null'
GROUP BY CO.customer_id
ORDER BY 1
--What was the difference between the longest and shortest delivery times for all orders?
SELECT 	 
		MAX(CAST(REGEXP_REPLACE(duration, '(mins|minutes|minute)', '', 'gi') AS NUMERIC)) -
		MIN(CAST(REGEXP_REPLACE(duration, '(mins|minutes|minute)', '', 'gi') AS NUMERIC)) AS difference
FROM runner_orders 
WHERE distance <>'null'

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,order_id,
		ROUND(AVG(
			CAST(REPLACE(distance,'km','') AS NUMERIC)/
			CAST(REGEXP_REPLACE(duration, '(mins|minutes|minute)', '', 'gi') AS NUMERIC)
			),2)AS avg_speed
FROM runner_orders
WHERE distance <>'null'
GROUP BY 1,2
ORDER BY 1,2
--What is the successful delivery percentage for each runner?
SELECT runner_id,
		CAST(SUM(CASE
			WHEN pickup_time <> 'null' THEN 1
			ELSE 0
			END) AS NUMERIC) /
		COUNT(order_id)
FROM runner_orders
GROUP BY runner_id


--C. Ingredient Optimisation
--What are the standard ingredients for each pizza?
WITH CTE AS(
		SELECT pizza_id,toppings,
				CAST(STRING_TO_TABLE(toppings,',') AS INTEGER) AS topping_id
		FROM pizza_recipes
 			)
SELECT CTE.pizza_id , PT.topping_name
FROM CTE
INNER JOIN pizza_toppings AS PT ON CTE.topping_id = PT.topping_id
ORDER BY pizza_id

--What was the most commonly added extra?
WITH CTE AS(
			SELECT order_id,CAST(STRING_TO_TABLE(extras,',') AS INTEGER) AS extras
			FROM customer_orders 
			WHERE extras <>'null' AND LENGTH(extras)>0
			)
SELECT extras,PT.topping_name,COUNT(extras) AS count
FROM CTE
INNER JOIN pizza_toppings AS PT ON CTE.extras = PT.topping_id
GROUP BY extras,2
ORDER BY count DESC
LIMIT 1
--What was the most common exclusion?
WITH CTE AS(
			SELECT order_id,CAST(STRING_TO_TABLE(exclusions,',') AS INTEGER) AS exclusions
			FROM customer_orders 
			WHERE exclusions <>'null' AND LENGTH(exclusions)>0
			)
SELECT exclusions,PT.topping_name,COUNT(exclusions) AS count
FROM CTE
INNER JOIN pizza_toppings AS PT ON CTE.exclusions = PT.topping_id
GROUP BY exclusions,2
ORDER BY count DESC
LIMIT 1