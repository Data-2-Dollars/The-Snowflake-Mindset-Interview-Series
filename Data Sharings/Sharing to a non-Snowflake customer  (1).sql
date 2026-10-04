USE ROLE ACCOUNTADMIN;

-- 1. Create the Reader Account
-- Note: Store the ADMIN_NAME and ADMIN_PASSWORD securely
CREATE MANAGED ACCOUNT customer_reader_acct
  ADMIN_NAME = 'customer_admin',
  ADMIN_PASSWORD = 'TemporaryPassword123!',
  TYPE = READER;

-- 2. Retrieve the URL for your customer
-- This command will show the account name and the URL they must use
SHOW MANAGED ACCOUNTS;

-- ===================

-- 3. Create the Share object
CREATE OR REPLACE SHARE reader_share;

-- 4. Grant access to your data
GRANT USAGE ON DATABASE sales_db TO SHARE reader_share;
GRANT USAGE ON SCHEMA sales_db.public TO SHARE reader_share;
GRANT SELECT ON TABLE sales_db.public.client_report TO SHARE reader_share;

-- 5. Add the Reader Account to the share
-- Use the account name found in 'SHOW MANAGED ACCOUNTS'
ALTER SHARE reader_share ADD ACCOUNTS = <READER_ACCOUNT_NAME>;


-- =====================

-- Setup the Reader Account (Consumer Side)

-- (Customer logs in using the credentials you created)
USE ROLE ACCOUNTADMIN;

-- 1. Create a Warehouse (Optional, but often pre-created by Provider)
-- Note: The Provider pays for this compute!
CREATE WAREHOUSE IF NOT EXISTS reader_wh WAREHOUSE_SIZE = 'XSMALL';

-- 2. Create the database from the share
CREATE DATABASE shared_data FROM SHARE <PROVIDER_ACCOUNT>.reader_share;

-- 3. Query the data
SELECT * FROM shared_data.public.client_report;


-- ========================
