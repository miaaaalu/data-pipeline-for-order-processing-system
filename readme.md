# 1. IMBA Entity Relationship Diagram(ERD) Design

This ERD example models a simple order system with the following entities:

* Aisles: stores aisles’s data.
* Departments: stores a list of products departments categories.
* Pdoducts: stores a list of products.
* Orders: stores sales orders placed by customers.
* OrdersProduct: stores order line items for each order.

![ER Diagram](https://github.com/miaaaalu/-Sample-ER-diagram-of-a-order-processing-system/blob/master/ER_model_diagram.png?raw=true)


## Products and Order_procducts 

Products --> Order_procducts
* A product colud be a part of <font color="#1ba1e2">no orders</font>, but it also could be a product of many orders, so the relationship from products to order is <font color="#1ba1e2">One to Zero/Many</font>.

Order_procducts --> Products
* An order colud be include one or multiple products, so the realship from odrder to products is <font color="#1ba1e2">One to One</font>.

## Products and Aisles 

Products --> Aisles
* A products can only include one aisles, so the relationship from products to aisles is <font color="#1ba1e2">One to One</font>.

Aisles --> Products
* A aisle colud be include one or multiple products, so the realship from aisles to products is <font color="#1ba1e2">One to One/Many</font>.

## Products and Departments 

Products --> Departments
* A products can only include one departments, so the relationship from products to departments is <font color="#1ba1e2">One to One</font>.

Departments --> Products
* A departments colud be include one or multiple products, so the realship from departments to products is <font color="#1ba1e2">One to One/Many</font>.

## Order_procducts and Orders 

Order_procducts --> Orders
* A products can only include one departments, so the relationship from products to departments is <font color="#1ba1e2">One to One</font>.

Orders --> Order_procducts
* A departments colud be include one or multiple products, so the realship from departments to products is <font color="#1ba1e2">One to One/Many</font>.

# 2. SQL Query from IMBA Data Set
Design a query to join orders table and order_products table together, filter on eval_set = ‘prior’
```sql
SELECT * 
FROM ORDERS
LEFT JOIN ORDER_PRODUCTS
    ON ORDERS.ORDER_ID = ORDER_PRODUCTS.ORDER_ID
WHERE eval_set = 'prior'
LIMIT 10;
```