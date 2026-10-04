-- Switch to a role with administrative privileges
USE ROLE ACCOUNTADMIN;

-- 1. Enable replication for the target account on the other cloud
-- Format: <Organization_Name>.<Account_Name>
ALTER ACCOUNT MY_ORG.AZURE_ACCOUNT SET IS_REPLICATION_ALLOWED = TRUE;

-- 2. Create a Failover Group (The container for replication)
CREATE OR REPLACE FAILOVER GROUP cross_cloud_share_group
  OBJECT_TYPES = DATABASES, SHARES
  ALLOWED_DATABASES = source_db
  ALLOWED_SHARES = source_share
  ALLOWED_ACCOUNTS = MY_ORG.AZURE_ACCOUNT
  REPLICATION_SCHEDULE = '10 MINUTE'; -- Automatically sync every 10 mins



  -- =======================

  ---Consumer side


  USE ROLE ACCOUNTADMIN;

-- 1. Create a replica of the failover group
CREATE FAILOVER GROUP cross_cloud_share_group
  AS REPLICA OF MY_ORG.AWS_ACCOUNT.cross_cloud_share_group;

-- 2. Manually trigger the initial sync (This takes time depending on data size)
ALTER FAILOVER GROUP cross_cloud_share_group REFRESH;

-- 3. Create the database from the replica
CREATE DATABASE shared_db_replica AS REPLICA OF MY_ORG.AWS_ACCOUNT.source_db;
