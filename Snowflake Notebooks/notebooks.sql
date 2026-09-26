-- Set context
USE ROLE ACCOUNTADMIN;
create or replace DATABASE SANDBOX_DB;
use SCHEMA PUBLIC;

-- 1. Create a basic notebook
CREATE OR REPLACE NOTEBOOK my_notebook_01;

-- 2. Describe the notebook metadata
DESCRIBE NOTEBOOK my_notebook_01;

-- 3. Create a notebook attached to a default Virtual Warehouse and comment
CREATE OR REPLACE NOTEBOOK my_notebook_02
    QUERY_WAREHOUSE = 'COMPUTE_WH'
    COMMENT = 'Production ETL Notebook for daily transformations';

-- 4. List all existing notebooks in current context
SHOW NOTEBOOKS;


create or replace role DATA_ENGINEER_ROLE;


-- Grant notebook creation privileges to a custom developer role
GRANT CREATE NOTEBOOK ON SCHEMA SANDBOX_DB.PUBLIC TO ROLE DATA_ENGINEER_ROLE;

-- Grant usage on the virtual warehouse
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DATA_ENGINEER_ROLE;


-- Create a table directly in a SQL cell
CREATE OR REPLACE TABLE sales_data (
    sale_id INT,
    product_name STRING,
    amount NUMBER(10,2)
);

-- Insert sample records
INSERT INTO sales_data VALUES 
(1, 'Laptop', 1200.00),
(2, 'Monitor', 300.00),
(3, 'Headphones', 150.00);

-- Query data
SELECT * FROM sales_data;
