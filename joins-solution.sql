-- 0. Get all the users
SELECT * FROM customers;

-- 1. Get all customers and their addresses.
SELECT * 
FROM "customers" JOIN "addresses"
ON "customers"."id" = "addresses"."customer_id";

-- 2. Get all orders and their line items (orders, quantity and product).
SELECT * FROM "orders"
JOIN "line_items" ON "orders"."id" = "line_items"."order_id"
JOIN "products" ON "products"."id" = "line_items"."product_id";

-- 3. Which warehouses have cheetos?
SELECT "warehouse"."warehouse" FROM "products"
JOIN "warehouse_product" ON "products"."id" = "warehouse_product"."product_id"
JOIN "warehouse" ON "warehouse"."id" = "warehouse_product"."warehouse_id"
WHERE "products"."description" = 'cheetos';

-- 4. Which warehouses have diet pepsi?
SELECT "warehouse"."warehouse" FROM "products"
JOIN "warehouse_product" ON "products"."id" = "warehouse_product"."product_id"
JOIN "warehouse" ON "warehouse"."id" = "warehouse_product"."warehouse_id"
WHERE "products"."description" = 'diet pepsi';

-- 5. Get the number of orders for each customer. NOTE: It is OK if those without orders are not included in results.
SELECT "customers"."first_name" AS "First Name", "customers"."last_name" AS "Last Name", COUNT("orders"."id") AS "Number of Orders" FROM "customers"
JOIN "addresses" ON "customers"."id" = "addresses"."customer_id"
JOIN "orders" ON "orders"."address_id" = "addresses"."id"
GROUP BY "customers"."id";

-- 6. How many customers do we have?
SELECT COUNT(*) FROM "customers";

-- 7. How many products do we carry?
SELECT COUNT(*) FROM "products";

-- 8. What is the total available on-hand quantity of diet pepsi?
SELECT SUM("warehouse_product"."on_hand") AS "Quantity Diet Pepsi" FROM "products"
JOIN "warehouse_product" ON "products"."id" = "warehouse_product"."product_id"
WHERE "products"."description" = 'diet pepsi'
GROUP BY "products"."id";

-- 9*. How much was the total cost for each order?
SELECT "orders"."id", SUM("line_items"."quantity" * "products"."unit_price") FROM "orders"
JOIN "line_items" ON "line_items"."order_id" = "orders"."id"
JOIN "products" ON "products"."id" = "line_items"."product_id"
GROUP BY "orders"."id";

-- 10*. How much has each customer spent in total?
SELECT 
    "customers"."first_name" AS "First Name", 
    "customers"."last_name" AS "Last Name", 
    SUM("line_items"."quantity" * "products"."unit_price") AS "Total Revenue" FROM "customers"
JOIN "addresses" ON "addresses"."customer_id" = "customers"."id"
JOIN "orders" ON "orders"."address_id" = "addresses"."id"
JOIN "line_items" ON "line_items"."order_id" = "orders"."id"
JOIN "products" ON "products"."id" = "line_items"."product_id"

-- 11*. How much has each customer spent in total? Customers who have spent $0 should still show up in the table. It should say 0, not NULL (research coalesce).
SELECT 
	"customers"."first_name" AS "First Name", 
	"customers"."last_name" AS "Last Name", 
	COALESCE(SUM("all_orders"."quantity" * "all_orders"."unit_price"), 0) AS "Total Revenue"
FROM "customers" 
LEFT OUTER JOIN (
	SELECT * FROM "addresses"
	JOIN "orders" ON "addresses"."id" = "orders"."address_id"
	JOIN "line_items" ON "orders"."id" = "line_items"."order_id"
	JOIN "products" ON "line_items"."product_id" = "products"."id"
) AS "all_orders" ON "customers"."id" = "all_orders"."customer_id"
GROUP BY "customers"."id"
ORDER BY "Total Revenue" DESC;