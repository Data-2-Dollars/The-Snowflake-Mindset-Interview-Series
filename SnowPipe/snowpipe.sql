-- Create Storage Integration with S3 Role ARN
CREATE OR REPLACE STORAGE INTEGRATION S3_SNOWPIPE_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<your-account-id>:role/snowflake_s3_role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://snowpipe-demo-2026/');

-- Describe integration to fetch AWS_IAM_USER_ARN and AWS_EXTERNAL_ID for S3 Trust Policy
DESCRIBE INTEGRATION S3_SNOWPIPE_INT;

-- Create CSV File Format
CREATE OR REPLACE FILE FORMAT MY_CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '\''
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE;

-- Target Table for Ingestion
CREATE OR REPLACE TABLE EMP_DATA (
    EMP_ID INT,
    EMP_NAME STRING,
    DEPARTMENT STRING,
    SALARY INT
);
-- Create External Stage
CREATE OR REPLACE STAGE MY_S3_STAGE
    URL = 's3://snowpipe-demo-2026/'
    STORAGE_INTEGRATION = S3_SNOWPIPE_INT;


-- Create Auto-Ingest Snowpipe
CREATE OR REPLACE PIPE MY_CSV_SNOWPIPE
    AUTO_INGEST = TRUE
AS
    COPY INTO EMP_DATA
    FROM @MY_S3_STAGE
    FILE_FORMAT = (FORMAT_NAME = MY_CSV_FORMAT);

-- Retrieve SQS Notification Channel (Copy this ARN to AWS S3 Event Notifications)
SHOW PIPES;

-- Query the Ingested Table
SELECT * FROM EMP_DATA;


-- Attach generated RSA Public Key to the Snowflake User
ALTER USER DATA2 DOLLARS 
SET RSA_PUBLIC_KEY = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...';

-- Verify the user setup and key assignment
DESCRIBE USER DATA2 DOLLARS;


-- Target Database & Schema context
USE DATABASE DEMODB;
USE SCHEMA PUBLIC;

-- Target Table for Real-Time Streaming Data
CREATE OR REPLACE TABLE SENSOR_READINGS (
    SENSOR_ID STRING,
    TEMPERATURE FLOAT,
    HUMIDITY FLOAT,
    READING_TIME TIMESTAMP_NTZ
);

-- Query real-time streamed records
SELECT * FROM SENSOR_READINGS;
