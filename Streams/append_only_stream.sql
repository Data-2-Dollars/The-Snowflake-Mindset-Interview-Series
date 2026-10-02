-- Re-create clean customers table
CREATE OR REPLACE TABLE customers (
    customer_id INT,
    name STRING,
    email STRING,
    status STRING
);

-- 1. Create Append-Only Stream
CREATE OR REPLACE STREAM strm_customers_append ON TABLE customers
APPEND_ONLY = TRUE;

SELECT * FROM strm_customers_append;

-- 2. Insert records
INSERT INTO customers VALUES 
(101, 'Jasbinder', 'chess@pirategmail.com', 'active'),
(102, 'Deep', 'ps@gmail.com', 'pending');

SELECT * FROM strm_customers_append;

-- 3. Delete records (Append-only stream ignores deletes)
DELETE FROM customers WHERE customer_id < 200;

SELECT * FROM strm_customers_append;

-- Re-insert records
INSERT INTO customers VALUES 
(101, 'Jasbinder', 'chess@pirategmail.com', 'active'),
(102, 'Deep', 'ps@gmail.com', 'pending');

-- 4. Update records (Append-only stream ignores updates)
UPDATE customers SET status = 'updated' WHERE customer_id = 101;

SELECT * FROM strm_customers_append;

-- 5. Helper Function: Check if Stream has data
SELECT SYSTEM$STREAM_HAS_DATA('strm_customers_append');
