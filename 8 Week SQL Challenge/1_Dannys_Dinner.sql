/*
8 Week SQL Challenge
Case Study #1 - Danny's Diner
https://8weeksqlchallenge.com/case-study-1/

Antonio Rendon
*/


-- Steps to create schema, tables and load data 
CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');




/*
Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:
*/

-- What is the total amount each customer spent at the restaurant?

SELECT S.customer_id,
       SUM(M.price) AS TotalSpent
FROM sales AS S
LEFT JOIN menu AS M ON S.product_id=M.product_id
GROUP BY S.customer_id;

-- How many days has each customer visited the restaurant?

SELECT S.customer_id,
       COUNT (DISTINCT S.order_date)
FROM sales AS S
GROUP BY 1;

--What was the first item from the menu purchased by each customer?

WITH CTE AS (
			SELECT S.customer_id,
			       M.product_name ,
				   ROW_NUMBER() OVER (PARTITION BY S.customer_id
			                             ORDER BY S.order_date ASC
			                            ) AS rn
			FROM sales AS S INNER JOIN menu as M ON S.product_id = M.product_id
	)

SELECT customer_id, 
	   product_name 
FROM CTE 
WHERE rn =1;

--What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT M.product_name,
       COUNT(S.product_id) AS total_purchases
FROM sales AS S
LEFT JOIN menu AS M ON S.product_id = M.product_id
GROUP BY M.product_name
ORDER BY total_purchases DESC
LIMIT 1; --Show only the most purchased

-- Which item was the most popular for each customer?
WITH populars AS (
		SELECT S.customer_id, 
				M.product_name,
       			COUNT(S.product_id) AS total_purchases,
	   			ROW_NUMBER() OVER (PARTITION BY S.customer_id
			                             ORDER BY COUNT(S.product_id) DESC
			                            ) AS rn
		FROM sales AS S
		LEFT JOIN menu AS M ON S.product_id = M.product_id
		GROUP BY M.product_name, S.customer_id
)

SELECT customer_id, 
	   product_name AS most_popular_product
FROM populars
WHERE rn =1;


--Which item was purchased first by the customer after they became a member?
WITH after_member AS (
		SELECT S.customer_id,
		M.product_name,
		S.order_date,
		ME.join_date,
		ROW_NUMBER() OVER (PARTITION BY S.customer_id
			                             ORDER BY order_date ASC
			                            ) AS rn
		FROM sales AS S
		INNER JOIN menu AS M ON S.product_id = M.product_id
		INNER JOIN members AS ME ON S.customer_id = ME.customer_id
		WHERE order_date >= join_date
		)
SELECT customer_id,
		product_name
FROM after_member
WHERE rn=1
-- Which item was purchased just before the customer became a member?

WITH before_member AS (
		SELECT S.customer_id,
		M.product_name,
		S.order_date,
		ME.join_date,
		ROW_NUMBER() OVER (PARTITION BY S.customer_id
			                             ORDER BY order_date DESC
			                            ) AS rn
		FROM sales AS S
		INNER JOIN menu AS M ON S.product_id = M.product_id
		INNER JOIN members AS ME ON S.customer_id = ME.customer_id
		WHERE order_date < join_date
		)
SELECT customer_id,
		product_name
FROM before_member
WHERE rn=1

--What is the total items and amount spent for each member before they became a member?

SELECT S.customer_id,
		COUNT(M.product_name) AS total_items,
		SUM(M.price) AS amount_spent
FROM sales AS S
INNER JOIN menu AS M ON S.product_id = M.product_id
INNER JOIN members AS ME ON S.customer_id = ME.customer_id 
WHERE order_date < join_date
GROUP BY S.customer_id

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT S.customer_id,
       SUM(CASE 
               WHEN M.product_name = 'sushi' THEN 20*M.price
               ELSE 10*M.price
           END) AS points
FROM sales AS S
JOIN menu AS M ON S.product_id = M.product_id
GROUP BY S.customer_id;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT S.customer_id,
       SUM(CASE
               WHEN S.order_date BETWEEN Me.join_date AND Me.join_date+INTERVAL '6 days' THEN 20*M.price
               ELSE 10*M.price
           END) AS points
FROM sales AS S
JOIN menu AS M ON S.product_id = M.product_id
JOIN members AS Me ON S.customer_id = Me.customer_id
WHERE S.order_date <='2021-01-31'
GROUP BY S.customer_id ;

--  Bonus Questions
-- Join All The Things

SELECT S.customer_id, S.order_date,M.product_name, M.price,
	CASE
		WHEN S.order_date >= ME.join_date THEN 'Y'
		ELSE 'N'
		END AS Member
FROM sales AS S
INNER JOIN menu AS M ON S.product_id = M.product_id
LEFT JOIN members AS ME ON S.customer_id = ME.customer_id
ORDER BY S.customer_id,S.order_date ASC


-- Rank All The Things

WITH CTE AS (
	SELECT S.customer_id, S.order_date,M.product_name, M.price,
	CASE
		WHEN S.order_date >= ME.join_date THEN 'Y'
		ELSE 'N'
		END AS Member
	FROM sales AS S
	INNER JOIN menu AS M ON S.product_id = M.product_id
	LEFT JOIN members AS ME ON S.customer_id = ME.customer_id
	ORDER BY S.customer_id,S.order_date ASC
)

SELECT customer_id, order_date, product_name, price, member,
	CASE
		WHEN member ='N'THEN NULL
		ELSE ROW_NUMBER() OVER (PARTITION BY customer_id, member ORDER BY order_date ASC)
		END
FROM CTE
