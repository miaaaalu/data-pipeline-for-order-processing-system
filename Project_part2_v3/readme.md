# Project_part2_v3
## **1. Create a new table called order_products_prior**
```sql
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
```

## **2. Create a SQL query (user_features_1)**

Based on table orders, for each user, calculate 
* the max order_number
* the sum of days_since_prior_order 
* the average of days_since_prior_order

```sql
SELECT user_id,
       MAX(order_number) AS max_order_num,
       SUM(days_since_prior_order) AS sum_of_days_since_prior_order,
       ROUND(AVG(days_since_prior_order),2) AS avg_of_days_since_prior_order
FROM orders
GROUP BY user_id
ORDER BY user_id
LIMIT 10;
```
|USER_ID|MAX_ORDER_NUM|SUM_OF_DAYS_SINCE_PRIOR_ORDER|AVG_OF_DAYS_SINCE_PRIOR_ORDER|
|-------|-------------|-----------------------------|-----------------------------|
|1      |11           |190                          |19                           |
|2      |15           |228                          |16.29                        |
|3      |13           |144                          |12                           |
|4      |6            |85                           |17                           |
|5      |5            |46                           |11.5                         |
|6      |4            |40                           |13.33                        |
|7      |21           |209                          |10.45                        |
|8      |4            |70                           |23.33                        |
|9      |4            |66                           |22                           |
|10     |6            |109                          |21.8                         |

## **3. Create a SQL query (user_features_2)**
Similar to above, based on table order_products_prior, for each user calculate
* the total number of products
* total number of distinct products
* user reorder ratio (number of reordered = 1 divided by number of order_number > 1)

```sql
# snowflake
SELECT user_id,
       COUNT(product_id) AS total_num_of_pro,
       COUNT(DISTINCT product_id) AS total_num_of_distinct_pro,
       ROUND(COUNT(CASE WHEN REORDERED = 1 THEN 1 END) / 
             COUNT(CASE WHEN ORDER_NUMBER > 1 THEN 1 END),2) 
             AS reorder_ratio
FROM order_products_prior
GROUP BY user_id
ORDER BY user_id
LIMIT 10;
```

```sql
# Athena
SELECT user_id,
       COUNT(product_id) AS total_num_of_pro,
       COUNT(DISTINCT product_id) AS total_num_of_distinct_pro,
       ROUND(COUNT(CASE WHEN REORDERED = 1 THEN 1 END) * 1.0 / 
             COUNT(CASE WHEN ORDER_NUMBER > 1 THEN 1 END),2) AS reorder_ratio
FROM order_products_prior
GROUP BY user_id
ORDER BY user_id
LIMIT 10;
```
|USER_ID|TOTAL_NUM_OF_PRO|TOTAL_NUM_OF_DISTINCT_PRO|REORDER_RATIO|
|-------|----------------|-------------------------|-------------|
|1      |59              |18                       |0.76         |
|2      |195             |102                      |0.51         |
|3      |88              |33                       |0.71         |
|4      |18              |17                       |0.07         |
|5      |37              |23                       |0.54         |
|6      |14              |12                       |0.20         |
|7      |206             |68                       |0.71         |
|8      |49              |36                       |0.46         |
|9      |76              |58                       |0.39         |
|10     |143             |94                       |0.36         |

## **4. Create a SQL query (up_features)**
Based on table order_products_prior, for each user and product, calculate 
* the total number of orders
* minimum order_number
* maximum order_number
* average add_to_cart_order
```sql
SELECT user_id, 
       product_id,
       COUNT(*) AS total_num_of_orders,
       MIN(order_number) AS min_order_number,
       MAX(order_number) AS max_order_number,
       ROUND(AVG(add_to_cart_order),2) AS avg_add_to_cart_order
FROM order_products_prior
GROUP BY user_id, product_id
ORDER BY user_id, product_id
LIMIT 10;
```

|USER_ID|PRODUCT_ID|TOTAL_ORDERS|MIN_ORD_NUM|MAX_ORD_NUM|AVG_ADD_TO_CART_ORDER|
|-------|----------|------------|--------------|--------------|---------------------|
|1      |196       |10          |1             |10            |1.40                 |
|1      |10258     |9           |2             |10            |3.33                 |
|1      |10326     |1           |5             |5             |5.00                 |
|1      |12427     |10          |1             |10            |3.30                 |
|1      |13032     |3           |2             |10            |6.33                 |
|1      |13176     |2           |2             |5             |6.00                 |
|1      |14084     |1           |1             |1             |2.00                 |
|1      |17122     |1           |5             |5             |6.00                 |
|1      |25133     |8           |3             |10            |4.00                 |
|1      |26088     |2           |1             |2             |4.50                 |


## **5. Create a SQL query (prd_features)**
Based on table order_products_prior, first write a sql query to calculate 
* the sequence of product purchase for each user, 
* and name it product_seq_time. 

Then on top of this query, for each product, calculate 
* the count, sum of reordered, 
* count of product_seq_time = 1 and 
* count of product_seq_time = 2.

```sql
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
```
|USER_ID|PRODUCT_ID|COUNT_OF_REORDERED|TOTAL_OF_REORDERED|SEQ_TIME_1|SEQ_TIME_2|
|-------|----------|------------------|------------------|----------|----------|
|1      |196       |10                |9                 |1         |1         |
|1      |10258     |9                 |8                 |1         |1         |
|1      |10326     |1                 |0                 |1         |0         |
|1      |12427     |10                |9                 |1         |1         |
|1      |13032     |3                 |2                 |1         |1         |
|1      |13176     |2                 |1                 |1         |1         |
|1      |14084     |1                 |0                 |1         |0         |
|1      |17122     |1                 |0                 |1         |0         |
|1      |25133     |8                 |7                 |1         |1         |
|1      |26088     |2                 |1                 |1         |1         |

