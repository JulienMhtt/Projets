USE toys_and_models;

# Query: orderdetails with amount per orderLineNumber
SELECT d.orderNumber, d.quantityOrdered, d.priceEach, d.quantityOrdered * d.priceEach AS amount,
	d.orderLineNumber
FROM orderdetails AS d
ORDER BY d.orderNumber, d.orderLineNumber;

# Query: orderdetails with order number, amount and number of lines per order
SELECT d.orderNumber, SUM(d.quantityOrdered * d.priceEach) AS orderAmount, COUNT(*) AS nb_lines
FROM orderdetails AS d
GROUP BY d.orderNumber
ORDER BY d.orderNumber;

# Query: orders per customer
SELECT c.customerNumber, c.customerName, o.orderNumber,
	SUM(d.quantityOrdered * d.priceEach) AS total_order_amount, COUNT(d.orderLineNumber) AS line_nb,
    o.orderDate, o.shippedDate, o.status
FROM orders AS o
	LEFT JOIN orderdetails AS d ON o.orderNumber = d.orderNumber
    INNER JOIN customers AS c ON o.customerNumber = c.customerNumber
WHERE o.status NOT IN ('shipped', 'resolved')
GROUP BY c.customerNumber, c.customerName, o.orderNumber, o.orderDate, o.shippedDate, o.status
ORDER BY o.orderDate;

# Query: number and total amount of orders per customer
SELECT c.customerNumber, SUM(d.quantityOrdered * d.priceEach) AS total_amount_orders,
	COUNT(o.orderNumber) AS nb_orders
FROM orders AS o
	INNER JOIN orderdetails AS d ON o.orderNumber = d.orderNumber
    INNER JOIN customers AS c ON o.customerNumber = c.customerNumber
GROUP BY c.customerNumber;

# Query: payments per customer
SELECT c.customerNumber, c.customerName, p.checkNumber, p.amount, p.paymentDate
FROM customers AS c
	INNER JOIN payments AS p ON c.customerNumber = p.customerNumber
ORDER BY p.paymentDate;

# Query: total amount paid per customer
SELECT c.customerNumber, SUM(p.amount) AS total_amount_paid
FROM customers AS c
	INNER JOIN payments AS p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber;

# Query: total unpaid amount of orders per customer
SELECT o.customerNumber, o.customerName, o.total_amount_orders, SUM(p.amount) AS total_amount_paid,
	(o.total_amount_orders - SUM(p.amount)) AS unpaid_amount, o.creditLimit, nb_orders
FROM (
	SELECT c.customerNumber, c.customerName, SUM(d.quantityOrdered * d.priceEach) AS total_amount_orders,
		c.creditLimit, COUNT(o.orderNumber) AS nb_orders
	FROM orders AS o
		INNER JOIN orderdetails AS d ON o.orderNumber = d.orderNumber
		INNER JOIN customers AS c ON o.customerNumber = c.customerNumber
	GROUP BY c.customerNumber) AS o
    INNER JOIN payments AS p ON o.customerNumber = p.customerNumber
GROUP BY o.customerNumber;

# Query: total unpaid amount of orders per customer with status not in (cancelled, on hold)
SELECT o.customerNumber, o.customerName, o.total_amount_orders, SUM(p.amount) AS total_amount_paid,
	(o.total_amount_orders - SUM(p.amount)) AS unpaid_amount, o.creditLimit, nb_orders
FROM (
	SELECT c.customerNumber, c.customerName, SUM(d.quantityOrdered * d.priceEach) AS total_amount_orders,
		c.creditLimit, COUNT(o.orderNumber) AS nb_orders
	FROM orders AS o
		INNER JOIN orderdetails AS d ON o.orderNumber = d.orderNumber
		INNER JOIN customers AS c ON o.customerNumber = c.customerNumber
	WHERE o.status NOT IN ('cancelled', 'on hold')
    GROUP BY c.customerNumber) AS o
    INNER JOIN payments AS p ON o.customerNumber = p.customerNumber
GROUP BY o.customerNumber
HAVING unpaid_amount != 0
ORDER BY o.customerNumber;

# Query: total orders and payments amounts per customer
CREATE OR REPLACE VIEW amounts_orders_payments_per_customer AS
	SELECT amount_orders.customerNumber, amount_orders.customerName, total_amount_orders, SUM(p.amount) AS total_amount_paid,
		(total_amount_orders - SUM(p.amount)) AS unpaid_amount, nb_orders
	FROM (
		SELECT c.customerNumber, c.customerName, SUM(d.quantityOrdered * d.priceEach) AS total_amount_orders,
			COUNT(o.orderNumber) AS nb_orders
		FROM orders AS o
			INNER JOIN orderdetails AS d ON o.orderNumber = d.orderNumber
			INNER JOIN customers AS c ON o.customerNumber = c.customerNumber
		GROUP BY c.customerNumber) AS amount_orders
		INNER JOIN payments AS p ON amount_orders.customerNumber = p.customerNumber
	GROUP BY amount_orders.customerNumber;

SELECT * FROM amounts_orders_payments_per_customer;

# Query: sum of order amounts per customer number, per order number and order date
SELECT c.customerNumber, o.orderNumber, SUM(d.priceEach * d.quantityOrdered) AS orderAmount,
	o.orderDate
FROM orders AS o
	INNER JOIN orderdetails AS d ON o.orderNumber = d.orderNumber
	INNER JOIN customers AS c ON o.customerNumber = c.customerNumber
GROUP BY c.customerNumber, o.orderNumber, o.orderDate
ORDER BY o.orderDate ASC;

# Query: sum of order amounts per customer number, per order number, order date, and checkNumber
# with INNER JOIN payments
# NOT OK! DON'T USE THIS!
SELECT c.customerNumber, o.orderNumber, SUM(d.priceEach * d.quantityOrdered) AS orderAmount,
	o.orderDate, p.checkNumber
FROM orders AS o
	INNER JOIN orderdetails AS d ON o.orderNumber = d.orderNumber
	INNER JOIN customers AS c ON o.customerNumber = c.customerNumber
    INNER JOIN payments AS p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, o.orderNumber, o.orderDate, p.checkNumber
ORDER BY o.orderDate ASC;