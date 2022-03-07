# 1. IMBA Entity Relationship Diagram(ERD) Design

This ERD example models a simple order system with the following entities:

* Aisles: stores aisles’s data.
* Departments: stores a list of products departments categories.
* Pdoducts: stores a list of products.
* Orders: stores sales orders placed by customers.
* OrdersProduct: stores order line items for each order.

![ER Diagram](https://github.com/miaaaalu/-Sample-ER-diagram-of-a-order-processing-system/blob/master/er_model_assets/ER_model_diagram.png?raw=true)


## Products and Order_procducts Table

Products --> Order_procducts
* A product colud be a part of **no orders**, but it also could be a product of many orders, so the relationship from products to order is **One to Zero/Many**.

Order_procducts --> Products
* An order line colud be include one or multiple products, so the realship from odrder to products is **One to One**.

![ER Diagram](https://github.com/miaaaalu/-Sample-ER-diagram-of-a-order-processing-system/blob/master/er_model_assets/order_products%20-%20Products.png?raw=true)

## Products and Aisles Table

Products --> Aisles
* A products can only include one aisles, so the relationship from products to aisles is **One to One**.

Aisles --> Products
* A aisle colud be include one or multiple products, so the realship from aisles to products is **One to One/Many**.

![ER Diagram](https://github.com/miaaaalu/-Sample-ER-diagram-of-a-order-processing-system/blob/master/er_model_assets/products-aisles.png?raw=true)

## Products and Departments Table 

Products --> Departments
* A products can only include one departments, so the relationship from products to departments is **One to One**.

Departments --> Products
* A departments colud be include one or multiple products, so the realship from departments to products is **One to One/Many**.

![ER Diagram](https://github.com/miaaaalu/-Sample-ER-diagram-of-a-order-processing-system/blob/master/er_model_assets/products-departments.png?raw=true)

## Order_procducts and Orders Table

Order_procducts --> Orders
* An order can have multiple products; each product will be shown in a separate line (called as OrderLine) in the Order_procducts table. So there can be one or more order lines for a single order, so the realtionship from Order_procducts to Orders table is **One to One**.

Orders --> Order_procducts
* For each order, there will be one or more order lines in Order_procducts table. However, if an order gets cancelled (destroyed) or any other specific reason, then order lines could be not exist in Order Products table. So the relationship from Orders to Order_procducts is **One to Zero/Many**.

![ER Diagram](https://github.com/miaaaalu/-Sample-ER-diagram-of-a-order-processing-system/blob/master/er_model_assets/order_products%20-%20orders.png?raw=true)

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