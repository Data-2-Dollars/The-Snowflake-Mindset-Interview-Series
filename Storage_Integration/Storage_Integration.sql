USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION s3_lake_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::192:role/SNF_DEMO'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflakedemoutube');



  DESC INTEGRATION s3_lake_integration;

  create or replace stage secure_s3_event_stage
  URL = 's3://snowflakedemoutube'
  STORAGE_INTEGRATION = s3_lake_integration;


  LIST@secure_s3_event_stage;

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;
