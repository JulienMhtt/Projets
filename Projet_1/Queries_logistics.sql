# PROJET 1


# orderdetails.quatityOrdered / products.productCode, products.productName, products.productLine,
# product.quantityInStock

# Le stock des 5 produits les plus commandés
SELECT products.productName, products.productLine, products.productCode, products.quantityInStock
FROM products
INNER JOIN orderdetails ON products.productCode = orderdetails.productCode
ORDER BY orderdetails.quantityOrdered
LIMIT 5;
## WARNING Les produits n'ont pas tous la même taille donc difficile d'avoir du stock sur les gros produits
## Voir ProductDescription

# Le stock des 5 produits les moins commandés
SELECT products.productName, products.productLine, products.productCode, products.quantityInStock
FROM products
INNER JOIN orderdetails ON products.productCode = orderdetails.productCode
ORDER BY orderdetails.quantityOrdered DESC
LIMIT 5;

# Livraison en attente 
SELECT products.productName,orderdetails.orderNumber, orders.status, orders.comments
FROM orderdetails
INNER JOIN orders ON orderdetails.orderNumber = orders.orderNumber
INNER JOIN products ON orderdetails.productCode = products.productCode
WHERE orders.status = "On Hold";

# Quantité moyenne commandé par mois par produit
SELECT products.productCode, products.productName,
MONTH(orders.orderDate) as m_month, AVG(orderdetails.quantityOrdered) as average_quantity_ordered
FROM orderdetails
INNER JOIN orders ON orderdetails.orderNumber = orders.orderNumber
INNER JOIN products ON orderdetails.productCode = products.productCode
GROUP BY m_month, products.productCode, products.productName
ORDER BY m_month ASC;

# Stock critique
SELECT productCode, productName, m_month, SUM(quantityInStock - average_quantity_ordered) as diff
FROM (SELECT products.productCode, products.productName,
	MONTH(orders.orderDate) as m_month, ROUND(AVG(orderdetails.quantityOrdered)) as average_quantity_ordered,
    products.quantityInStock
	FROM orderdetails
	INNER JOIN orders ON orderdetails.orderNumber = orders.orderNumber
	INNER JOIN products ON orderdetails.productCode = products.productCode
	GROUP BY m_month, products.productCode, products.productName
	ORDER BY m_month ASC) as t
WHERE m_month = 4
GROUP BY m_month, productCode, productName
ORDER BY diff ASC;

# Aucun produit n'a été vendu au dessus de son MSRP
SELECT *
FROM(
	SELECT products.productCode, products.buyPrice, products.MSRP, orderdetails.priceEach, customers.salesRepEmployeeNumber,
	(orderdetails.priceEach - products.MSRP) AS diff_MSRP
	FROM orderdetails
	INNER JOIN products ON products.productCode = orderdetails.productCode
	INNER JOIN orders ON orders.orderNumber = orderdetails.orderNumber
	LEFT JOIN customers ON customers.customerNumber = orders.customerNumber
	ORDER BY customers.salesRepEmployeeNumber) as sub
WHERE diff_MSRP > 0;

# % de marge par produit vendu
SELECT *
FROM(
SELECT products.productCode, products.buyPrice, products.MSRP, orderdetails.priceEach, customers.salesRepEmployeeNumber,
ROUND(((orderdetails.priceEach - products.buyPrice) / orderdetails.priceEach) * 100) AS percent_margin
FROM orderdetails
INNER JOIN products ON products.productCode = orderdetails.productCode
INNER JOIN orders ON orders.orderNumber = orderdetails.orderNumber
LEFT JOIN customers ON customers.customerNumber = orders.customerNumber
ORDER BY products.productCode) as sub
ORDER BY products.productCode, percent_margin;

# % de marge par commande 
CREATE VIEW sub_sub AS
SELECT sub.orderNumber, SUM(sub.total_sales) as total_order, SUM(sub.total_buyPrice) as total_buyPrice_order
FROM
	(SELECT orderdetails.orderNumber, orderdetails.productCode, orderdetails.quantityOrdered, orderdetails.priceEach,
	(orderdetails.quantityOrdered * orderdetails.priceEach) as total_sales, products.buyPrice,
    (orderdetails.quantityOrdered * products.buyPrice) as total_buyPrice,
    orders.comments
	FROM orderdetails
    INNER JOIN orders ON orders.orderNumber = orderdetails.orderNumber
    INNER JOIN products ON orderdetails.productCode = products.productCode) as sub
GROUP BY sub.orderNumber;

SELECT sub_sub.orderNumber, ROUND(((total_order - total_buyPrice_order) / total_order) * 100) AS percent_margin_order,
customers.salesRepEmployeeNumber ,orders.comments
FROM sub_sub
INNER JOIN orders ON sub_sub.orderNumber = orders.orderNumber
LEFT JOIN customers ON customers.customerNumber = orders.customerNumber
GROUP BY orderNumber
ORDER BY percent_margin_order;

# Taux de marge par vendeur
SELECT customers.salesRepEmployeeNumber, ROUND(AVG(((total_order - total_buyPrice_order) / total_order) * 100)) AS avg_margin_salesRep
FROM sub_sub
INNER JOIN orders ON sub_sub.orderNumber = orders.orderNumber
LEFT JOIN customers ON customers.customerNumber = orders.customerNumber
GROUP BY customers.salesRepEmployeeNumber
ORDER BY avg_margin_salesRep;


