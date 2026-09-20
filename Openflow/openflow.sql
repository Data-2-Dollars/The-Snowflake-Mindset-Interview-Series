-- =============================================================
-- Openflow Demo Setup (Gen 1 - Snowflake Deployment)
-- =============================================================

USE ROLE ACCOUNTADMIN;

-- Step 1: Create the Openflow admin role
CREATE ROLE IF NOT EXISTS OPENFLOW_DEMO_ADMIN;

-- Step 2: Grant required account-level privileges
GRANT CREATE COMPUTE POOL ON ACCOUNT TO ROLE OPENFLOW_DEMO_ADMIN;

GRANT CREATE OPENFLOW DATA PLANE INTEGRATION ON ACCOUNT
    TO ROLE OPENFLOW_DEMO_ADMIN;

GRANT CREATE OPENFLOW RUNTIME INTEGRATION ON ACCOUNT
    TO ROLE OPENFLOW_DEMO_ADMIN;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE OPENFLOW_DEMO_ADMIN;

GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE OPENFLOW_DEMO_ADMIN;

-- Step 3: Assign the role to the current user
SET CURR_USER=(SELECT CURRENT_USER());

GRANT ROLE OPENFLOW_DEMO_ADMIN TO USER IDENTIFIER($CURR_USER);

-- Step 4: Set default secondary roles (required for Openflow login)
ALTER USER IDENTIFIER($CURR_USER) SET DEFAULT_SECONDARY_ROLES = ('ALL');

-- Step 5: Check behavior change bundle status (BCR-1692)
CALL SYSTEM$BEHAVIOR_CHANGE_BUNDLE_STATUS('2024_08');

-- IMPORTANT: If the 2024_08 bundle is NOT enabled, run:
-- CALL SYSTEM$ENABLE_BEHAVIOR_CHANGE_BUNDLE('2024_08');

-- Step 6: Verify grants
SHOW GRANTS TO ROLE OPENFLOW_DEMO_ADMIN;

-- =============================================================
-- Create Openflow infrastructure database and warehouse
-- =============================================================
USE ROLE OPENFLOW_DEMO_ADMIN;

CREATE DATABASE IF NOT EXISTS OPENFLOW_DEMO_DB;

CREATE SCHEMA IF NOT EXISTS OPENFLOW_DEMO_DB.OPENFLOW_SCHEMA;

CREATE WAREHOUSE IF NOT EXISTS OPENFLOW_DEMO_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

-- =============================================================
-- Create the execute-as role for connector authentication
-- =============================================================
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS OPENFLOW_DEMO_EXECUTE_AS_RL;

GRANT ROLE OPENFLOW_DEMO_EXECUTE_AS_RL TO ROLE OPENFLOW_DEMO_ADMIN;

GRANT USAGE ON DATABASE OPENFLOW_DEMO_DB TO ROLE OPENFLOW_DEMO_EXECUTE_AS_RL;

GRANT USAGE ON SCHEMA OPENFLOW_DEMO_DB.OPENFLOW_SCHEMA TO ROLE OPENFLOW_DEMO_EXECUTE_AS_RL;

GRANT USAGE, OPERATE ON WAREHOUSE OPENFLOW_DEMO_WH TO ROLE OPENFLOW_DEMO_EXECUTE_AS_RL;





-- ===================================
-- PART-2
-- ===================================

-- Text extracted from image_11.png
USE ROLE accountadmin;

USE DATABASE JAS_DEMO;
USE SCHEMA networks;

-- The following CREATE OR REPLACE NETWORK RULE statement is present in both images
CREATE OR REPLACE NETWORK RULE JAS_DEMO.networks.snowflake_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = (
    '*.snowflakecomputing.com'
  )
  COMMENT='Allows only connections to Snowflake Services e.g. Stage';

-- Text extracted from image_12.png (continuing after the common rule definition)
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION quickstart_access
  ALLOWED_NETWORK_RULES = ('JAS_DEMO.networks.snowflake_network_rule')
  ENABLED = TRUE;

GRANT USAGE ON INTEGRATION quickstart_access TO ROLE OPENFLOW_DEMO_ADMIN;
