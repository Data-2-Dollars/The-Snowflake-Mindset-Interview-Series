-- 1. Switch to Account Admin
USE ROLE ACCOUNTADMIN;

-- 2. Enable replication for the target account (if not already done)
-- Replace 'MY_ORG' and 'CONSUMER_ACCT' with actual names
ALTER ACCOUNT MY_ORG.CONSUMER_ACCT SET IS_REPLICATION_ALLOWED = TRUE;

-- 3. Create a Replication Group
-- This "packages" the database for transport to the other region
CREATE OR REPLACE REPLICATION GROUP cross_region_share_group
  OBJECT_TYPES = DATABASES
  ALLOWED_DATABASES = source_db
  ALLOWED_ACCOUNTS = MY_ORG.CONSUMER_ACCT;

/*=============================================
===============================================
=============================================*/

  -- 1. Create a replica of the group from the primary account
-- This creates a read-only "link" in the consumer's region
CREATE REPLICATION GROUP cross_region_share_group
  AS REPLICA OF MY_ORG.PRIMARY_ACCT.cross_region_share_group;

-- 2. Manually trigger the first refresh (initial data transfer)
-- Note: This will incur data transfer costs based on size
ALTER REPLICATION GROUP cross_region_share_group REFRESH;

-- 3. Create a local secondary database from the replication
CREATE DATABASE shared_db_replica 
  AS REPLICA OF MY_ORG.PRIMARY_ACCT.source_db;


/*=============================================
===============================================
=============================================*/
  -- 1. Create the Share in the secondary region
CREATE OR REPLACE SHARE local_cross_region_share;

-- 2. Grant permissions on the replicated database
GRANT USAGE ON DATABASE shared_db_replica TO SHARE local_cross_region_share;
GRANT USAGE ON SCHEMA shared_db_replica.public TO SHARE local_cross_region_share;
GRANT SELECT ON ALL TABLES IN SCHEMA shared_db_replica.public TO SHARE local_cross_region_share;

-- 3. Add the target local account
ALTER SHARE local_cross_region_share ADD ACCOUNTS = MY_ORG.TARGET_DEPT_ACCT;
