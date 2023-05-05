USE sales;


CREATE OR REPLACE VIEW transaction_info AS (
	SELECT
        m.markets_name,
        m.zone,
        p.product_type,
        c.customer_name,
        c.customer_type,
        t.order_date,
        t.sales_qty,
        t.sales_amount,
        t.currency
	FROM
		transactions t
        JOIN
        markets m
		ON
        m.markets_code = t.market_code
        JOIN
        products p
        ON p.product_code = t.product_code
        JOIN
        customers c
        ON c.customer_code = t.customer_code
);

SELECT * FROM transaction_info ORDER BY markets_name;

-- 1) How many transactions were there that used INR as the currency method?  
SELECT COUNT(*) FROM transactions;

-- 2) How many customers do we have in our database?
SELECT COUNT(*) 'total_customers' FROM customers;

-- 3)  Find the Average sales amount per month per market name?

SELECT
	markets_name,
    zone,
    DATE_FORMAT(order_date, '%Y-%m') 'year_month',
    ROUND(AVG(sales_amount), 2) 'avg_sales'
FROM
	transaction_info
GROUP BY
	markets_name, 3
ORDER BY
	3;
    
-- 4) Sum of sales per month?
SELECT
	DATE_FORMAT(order_date, '%Y-%m') 'year_month',
    FORMAT(SUM(sales_amount), 'C') 'sum_of_sales'
FROM
	transaction_info
GROUP BY
	1
ORDER BY
	1;
    
-- 5) find the average sales difference per month?

WITH cte AS
(SELECT
	DATE_FORMAT(order_date, '%Y-%m') 'ym',
    sales_amount
FROM
	transaction_info
ORDER BY
	1), cte2 AS 
    (
		SELECT
			ym,
			sales_amount,
			LAG(sales_amount) OVER(PARTITION BY ym ORDER BY sales_amount) 'prev_sale_amount'
		FROM
			cte
		ORDER BY
			ym
    ), cte3 AS
(
SELECT
	ym,
    sales_amount,
    prev_sale_amount,
    sales_amount - prev_sale_amount 'difference'
FROM
	cte2
)
SELECT
	ym,
    ROUND(AVG(difference), 0) 'avg_diff'
FROM
	cte3
GROUP BY
	ym;
    
-- 6) Return the month with the highest number of sales?

WITH cte AS (
	SELECT
		DATE_FORMAT(order_date, '%Y-%m') 'order_month',
		SUM(sales_amount) 'total_monthly_sales'
	FROM
		transaction_info
	GROUP BY
		1
)
SELECT
	order_month,
    FORMAT(total_monthly_sales, 'C') 'highest_sales_month'
FROM
	cte
WHERE
	total_monthly_sales = (
		SELECT
			MAX(total_monthly_sales)
		FROM
			cte
    );
    
-- 7) Return the top 3 highest sales per month?
WITH cte AS 
(
	SELECT
		DATE_FORMAT(order_date, '%Y-%m') 'order_month',
        SUM(sales_amount) 'sum_sales_month'
	FROM
		transaction_info
	GROUP BY
		1
	ORDER BY 
		1
), cte2 AS
(
	SELECT
		order_month,
        sum_sales_month,
        DENSE_RANK() OVER(ORDER BY sum_sales_month DESC) 'sales_rank'
	FROM
		cte
)
SELECT
	*
FROM	
	cte2
WHERE
	sales_rank <= 3;
    
-- 8) Find the average percentage change per month?
WITH cte AS
(
	SELECT
		DATE_FORMAT(order_date, '%Y-%m') 'order_month',
        AVG(sales_amount) 'avg_sales'
	FROM
		transaction_info
	GROUP BY
		1
	ORDER BY
		1
)
SELECT
	order_month,
    avg_sales,
    LEAD(avg_sales) OVER() 'next_val',
    CONCAT(ROUND((LEAD(avg_sales) OVER() - avg_sales) * 100 / avg_sales, 2), '%') 'percentage_change'
FROM	
	cte;

