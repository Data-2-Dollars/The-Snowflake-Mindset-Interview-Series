-- Use a high-level role
USE ROLE ACCOUNTADMIN;

-- 1. Create the Share container
CREATE OR REPLACE SHARE partner_outbound_share;

-- 2. Grant usage on the database and schema
-- (Assuming 'provider_db' and 'public' already exist)
GRANT USAGE ON DATABASE provider_db TO SHARE partner_outbound_share;
GRANT USAGE ON SCHEMA provider_db.public TO SHARE partner_outbound_share;

-- 3. Grant SELECT on specific data
-- It is best practice to use a SECURE VIEW for external shares
CREATE OR REPLACE SECURE VIEW provider_db.public.partner_data_view AS
SELECT customer_id, transaction_amount, date 
FROM provider_db.public.raw_transactions;

GRANT SELECT ON VIEW provider_db.public.partner_data_view TO SHARE partner_outbound_share;

-- =====================================
-- 4. Add the external account to the share
-- Format: <ORG_NAME>.<ACCOUNT_NAME>
ALTER SHARE partner_outbound_share ADD ACCOUNTS = EXTERNAL_ORG_XYZ.CONSUMER_ACCT_123;


-- =========================================

USE ROLE ACCOUNTADMIN;

-- 1. See if the share is available
SHOW SHARES;

-- 2. Create a local database from the external share
-- Format: <PROVIDER_ORG>.<PROVIDER_ACCT>.<SHARE_NAME>
CREATE OR REPLACE DATABASE partner_data_inbound 
  FROM SHARE PROVIDER_ORG_ABC.PROVIDER_ACCT_789.partner_outbound_share;

-- 3. Grant access to internal users
GRANT USAGE ON DATABASE partner_data_inbound TO ROLE data_analyst;
GRANT USAGE ON SCHEMA partner_data_inbound.public TO ROLE data_analyst;
GRANT SELECT ON ALL VIEWS IN SCHEMA partner_data_inbound.public TO ROLE data_analyst;
