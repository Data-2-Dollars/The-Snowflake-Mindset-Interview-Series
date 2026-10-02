-- 1. Create base table and target table
CREATE OR REPLACE TABLE customers (
    customer_id INT,
    name STRING,
    email STRING,
    status STRING
);

CREATE OR REPLACE TABLE customers_target (
    customer_id INT,
    name STRING,
    email STRING,
    status STRING,
    updated_at TIMESTAMP
);

-- 2. Create Standard Stream on table
CREATE OR REPLACE STREAM strm_customers_delta ON TABLE customers;

-- Query initial state
SELECT * FROM customers;
SELECT * FROM strm_customers_delta;

-- 3. Insert initial records
INSERT INTO customers VALUES 
(101, 'Jasbinder', 'chess@pirategmail.com', 'active'),
(102, 'Deep', 'ps@gmail.com', 'pending');

SELECT * FROM customers;
SELECT * FROM strm_customers_delta;

-- 4. Ingest/Consume data into Target Table
INSERT INTO customers_target
SELECT 
    customer_id, 
    name, 
    email, 
    status, 
    CURRENT_TIMESTAMP() AS updated_at
FROM strm_customers_delta
WHERE METADATA$ACTION = 'INSERT';

SELECT * FROM customers_target;
SELECT * FROM strm_customers_delta; -- Stream becomes empty after consumption

-- 5. DML Operations (Insert, Immediate Update, and Delete)
INSERT INTO customers VALUES (103, 'Charlie', 'ch@gmail.com', 'active');
UPDATE customers SET status = 'suspended' WHERE customer_id = 103;
DELETE FROM customers WHERE customer_id = 101;

SELECT * FROM strm_customers_delta;

-- 6. CDC Merge Statement using Stream
MERGE INTO customers_target AS T
USING strm_customers_delta AS S
ON T.customer_id = S.customer_id

-- Handle Deletions
WHEN MATCHED AND S.METADATA$ACTION = 'DELETE' AND S.METADATA$ISUPDATE = FALSE THEN 
    DELETE

-- Handle Updates
WHEN MATCHED AND S.METADATA$ACTION = 'INSERT' AND S.METADATA$ISUPDATE = TRUE THEN 
    UPDATE SET 
        T.name = S.name,
        T.email = S.email,
        T.status = S.status,
        T.updated_at = CURRENT_TIMESTAMP()

-- Handle Insertions
WHEN NOT MATCHED AND S.METADATA$ACTION = 'INSERT' THEN 
    INSERT (customer_id, name, email, status, updated_at)
    VALUES (S.customer_id, S.name, S.email, S.status, CURRENT_TIMESTAMP());

SELECT * FROM customers_target;

-- 7. Streams on Views
CREATE OR REPLACE VIEW v_active_customers AS 
SELECT customer_id, name, email 
FROM customers;

-- Create Stream on View
CREATE OR REPLACE STREAM strm_vactive ON VIEW v_active_customers;

UPDATE customers SET status = 'active' WHERE customer_id = 102;
SELECT * FROM strm_vactive;
