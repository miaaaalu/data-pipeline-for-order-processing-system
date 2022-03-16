-- 1. Create a new table called order_products_prior**
CREATE TABLE order_products_prior WITH (
	external_location = 's3://data-lake-bucket-imba/features/order_products_prior/', format = 'parquet'
) 
AS (
	SELECT ORDERS.*,
           ORDER_PRODUCTS.product_id,
           ORDER_PRODUCTS.add_to_cart_order,
           ORDER_PRODUCTS.reordered
	FROM ORDERS
	JOIN ORDER_PRODUCTS 
         ON ORDERS.ORDER_ID = ORDER_PRODUCTS.ORDER_ID
	WHERE eval_set = 'prior'
);

-- 2. Create a SQL query (user_features_1). Based on table orders, for each user, calculate the max order_number, the sum of days_since_prior_order and the average of days_since_prior_order.
SELECT user_id,
       MAX(order_number) AS max_order_num
       SUM(days_since_prior_order) AS sum_of_days_since_prior_order,
       ROUND(AVG(days_since_prior_order),2) AS avg_of_days_since_prior_order
FROM orders
GROUP BY user_id
ORDER BY user_id
LIMIT 10;

--  3.Create a SQL query (user_features_2). Similar to above,based on table order_products_prior, for each user calculate the total number of products, total number of distinct products, and user reorder ratio(number of reordered = 1 divided by number of order_number > 1)
SELECT user_id,
       COUNT(product_id) AS total_num_of_pro,
       COUNT(DISTINCT product_id) AS total_num_of_distinct_pro,
       ROUND(COUNT(CASE WHEN REORDERED = 1 THEN 1 END) / COUNT(CASE WHEN ORDER_NUMBER > 1 THEN 1 END),2) AS reorder_ratio
FROM order_products_prior
GROUP BY user_id
ORDER BY user_id
LIMIT 10;

--  4. Create a SQL query (up_features). Based on table order_products_prior, for each user and product, calculate the total number of orders, minimum order_number, maximum order_number and average add_to_cart_order.
SELECT user_id, 
       product_id,
       COUNT(DISTINCT order_id) AS total_orders,
       MIN(order_number) AS min_ord_num,
       MAX(order_number) AS max_ord_num,
       ROUND(AVG(add_to_cart_order),2) AS avg_add_to_cart_order
FROM order_products_prior
GROUP BY user_id, product_id
ORDER BY user_id, product_id
LIMIT 10;

--  5. Create a SQL query (prd_features). Based on table order_products_prior, first write a sql query to calculate the sequence of product purchase for each user, and name it product_seq_time. Then on top of this query, for each product, calculate the count, sum of reordered, count of product_seq_time = 1 and count of product_seq_time = 2.
WITH 
order_products_prior_seq AS 
  (SELECT *,
          ROW_NUMBER () OVER(PARTITION BY user_id, product_id ORDER BY order_number) AS product_seq_time
   FROM order_products_prior
  )

SELECT user_id,
       product_id,
       COUNT(reordered) AS count_of_reordered,
       SUM(reordered) AS total_of_reordered,
       COUNT(CASE WHEN PRODUCT_SEQ_TIME = 1 THEN 1 END) AS seq_time_1,
       COUNT(CASE WHEN PRODUCT_SEQ_TIME = 2 THEN 1 END) AS seq_time_2
FROM order_products_prior_seq
GROUP BY user_id,PRODUCT_ID
ORDER BY user_id,PRODUCT_ID
LIMIT 10;
