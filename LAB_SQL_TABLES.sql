-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW sakila.Customers_rental_info AS (
SELECT c.customer_id, c.first_name, c.last_name, 
c.email, r.rental_id
FROM sakila.customer as c
JOIN sakila.rental as r
ON c.customer_id = r.customer_id
);


-- - Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE Total_Amount_Paid AS (
  SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email, 
    SUM(p.amount) AS total_amount
  FROM sakila.customer AS c
  JOIN sakila.rental AS r ON c.customer_id = r.customer_id
  JOIN sakila.payment AS p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id, c.first_name, c.last_name, c.email
);

SELECT * from Total_Amount_Paid;


-- - Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid. 
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.


WITH CustomerSummaryCTE AS (
    SELECT
        tap.customer_id,
        CONCAT(tap.first_name, ' ', tap.last_name) AS customer_name,
        tap.email,
        COUNT(r.rental_id) AS rental_count,
        tap.total_amount AS total_paid,
        tap.total_amount / COUNT(r.rental_id) AS average_payment_per_rental
    FROM
        Total_Amount_Paid tap
    JOIN
        sakila.rental r ON tap.customer_id = r.customer_id
    GROUP BY
        tap.customer_id, customer_name, tap.email, tap.total_amount
)

SELECT
    customer_id,
    customer_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM
    CustomerSummaryCTE;

