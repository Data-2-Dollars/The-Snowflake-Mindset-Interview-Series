-- Use a role with sharing privileges
USE ROLE ACCOUNTADMIN;

-- Create a dummy database and table for the share
CREATE OR REPLACE DATABASE sales_db;
CREATE OR REPLACE SCHEMA sales_db.public;

CREATE OR REPLACE TABLE sales_db.public.regional_sales (
    region STRING,
    revenue NUMBER,
    report_date DATE
);

-- Insert sample data
INSERT INTO sales_db.public.regional_sales VALUES ('North', 50000, '2026-04-20'), ('South', 65000, '2026-04-21');
-- Create the share container
CREATE OR REPLACE SHARE sales_share;

-- Grant usage on the database and schema to the share
GRANT USAGE ON DATABASE sales_db TO SHARE sales_share;
GRANT USAGE ON SCHEMA sales_db.public TO SHARE sales_share;

-- Grant select on the specific table (or secure view)
GRANT SELECT ON TABLE sales_db.public.regional_sales TO SHARE sales_share;

/*=============================================
===============================================
=============================================*/


-- Add the consumer account to the share
-- Format: <org_name>.<account_name>
ALTER SHARE sales_share ADD ACCOUNTS = --<MY_ORG.MARKETING_DEPT>;


-- Switch to the consumer account role
USE ROLE ACCOUNTADMIN;

-- View available shares
SHOW SHARES;

-- Create a local database based on the provider's share
CREATE DATABASE marketing_sales_view FROM SHARE PROVIDER_ORG.SALES_ACCOUNT.sales_share;

-- Grant privileges to internal roles so they can query it
GRANT USAGE ON DATABASE marketing_sales_view TO ROLE --<ROLE> ;


SELECT * FROM --<table name> -- ;
