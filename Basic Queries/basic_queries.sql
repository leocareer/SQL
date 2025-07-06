-- List of countries that are shopping
SELECT DISTINCT country 'Countries that are shopping'
FROM company AS t1
JOIN transaction AS t2
ON t1.id = t2.company_id
ORDER BY country;

-- Рow many countries are shopping
SELECT count(DISTINCT country) 'How many countries are shopping'
FROM company AS t1
JOIN transaction AS t2
ON t1.id = t2.company_id;

-- Identify the company with the highest average sales (solution with 'limit')
SELECT company_name 'Company', ROUND(AVG(amount), 2) AS Average_sales
FROM transaction AS t1
JOIN company AS t2 
ON t2.id = t1.company_id
GROUP BY t1.company_id
ORDER BY Average_sales DESC
LIMIT 1;

-- Identify the company with the highest average sales (solution without 'limit')
SELECT company_name, Average_sales
FROM (
	SELECT company_id, ROUND(AVG(amount), 2) AS Average_sales 
    FROM transaction
    GROUP BY company_id
) AS t2
JOIN company AS t1 ON t1.id = t2.company_id
WHERE Average_sales = (
		SELECT max(avg_amount_t3) 
        FROM (
			SELECT ROUND(AVG(amount), 2) AS avg_amount_t3 FROM transaction
			GROUP BY company_id
		) AS t3
);

-- Show all transactions made by companies in Germany
SELECT * 
FROM transaction
WHERE company_id IN (
	SELECT id FROM company
    WHERE country = 'Germany'
);

-- List the companies that have made transactions for an amount higher than the average of all transactions
SELECT company_name 'Companies'
FROM company
WHERE id IN (
	SELECT company_id 
    FROM transaction
	WHERE amount > (
		SELECT AVG(amount) FROM transaction
	)
)
ORDER BY company_name;

-- Companies that do not have registered transactions will be removed from the system, provide the list of these companies
SELECT company_name 'Companies'
FROM company
WHERE NOT EXISTS (
	SELECT company_id 
    FROM transaction
    WHERE transaction.company_id = company_id
);

-- The five days that generated the largest amount of revenue for the company from sales. 
-- It shows the date of each transaction along with the sales total.

-- with 'limit'
SELECT sum(amount) 'Sales total', DATE(timestamp) 'Date'
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY sum(amount) DESC
LIMIT 5;

-- the second implementation option with window function without 'limit'
SELECT Sales_total, Sale_date
FROM (
	SELECT sum(amount) AS Sales_total, DATE(timestamp) AS Sale_date,
	ROW_NUMBER() OVER(ORDER BY sum(amount) DESC) AS ind_amount
    FROM transaction
    WHERE declined = 0
    GROUP BY Sale_date
) AS t
WHERE ind_amount <= 5
ORDER BY Sales_total;

-- What is the average sales per country? It presents the results sorted from highest to lowest average.
SELECT country 'Countries', ROUND(AVG(amount), 2) AS Average_sales
FROM transactions.company AS t1
JOIN transactions.transaction AS t2
ON t1.id = t2.company_id
WHERE declined = 0
GROUP BY country
ORDER BY Average_sales DESC;

-- The list of all transactions carried out by companies that are located in the same country as 'Non Institute' company.

-- with join
SELECT *
FROM transaction AS t1
JOIN company AS t2
ON t2.id = t1.company_id
WHERE country = (
	SELECT country FROM company
    WHERE company_name LIKE 'Non Institute'
)
AND company_name <> 'Non Institute'
ORDER BY company_name;

-- with only subqueries
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id FROM company
    WHERE country = (
		SELECT country FROM company
		WHERE company_name LIKE 'Non Institute'
        )
	AND company_name <> 'Non Institute'
);

-- It presents the name, telephone, country, date and amount of those companies that made transactions with a value between 100 and 200 euros and on any of these dates: 
-- April 29, 2021, July 20, 2021 and March 13, 2022. 
-- Sort the results from highest to lowest amount.
SELECT company_name, phone, country, DATE(timestamp) 'date', amount
FROM company AS t1
JOIN transaction AS t2
ON t1.id = t2.company_id
WHERE DATE(timestamp) IN ('2021-04-29','2021-07-20','2022-03-13')
AND amount BETWEEN 100 AND 200
ORDER BY amount DESC;

-- We need to optimize the allocation of resources and it will depend on the operational capacity that is required, 
-- so they ask you for the information about the amount of transactions that the companies carry out, 
-- but the HR department is demanding and wants a list of the companies where you specify if they have more than 4 transactions or less.
SELECT company_name,
	CASE 
		WHEN count(t2.id) >= 4 THEN '>= 4 transactions'
		ELSE '< 4 transactions'
	END AS transaction_count
FROM transactions.company AS t1
JOIN transactions.transaction AS t2
ON t1.id = t2.company_id
GROUP BY t1.id
ORDER BY transaction_count DESC;