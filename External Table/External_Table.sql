USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION s3_lake_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::1192:role/SNF_DEMO'
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

CREATE OR REPLACE EXTERNAL TABLE ext_employee_events (
    employee_id NUMBER(38,0) AS ($1:c1::NUMBER(38,0)),
    first_name STRING AS ($1:c2::STRING),
    last_name STRING AS ($1:c3::STRING),
    email STRING AS ($1:c4::STRING),
    phone_number STRING AS ($1:c5::STRING),
    hire_date DATE AS (TRY_TO_DATE($1:c6::STRING, 'DD-MON-YY')),
    job_id STRING AS ($1:c7::STRING),
    salary NUMBER(10,2) AS (TRY_TO_DECIMAL($1:c8::STRING, 10, 2)),
    commission_pct NUMBER(10,2) AS (TRY_TO_DECIMAL($1:c9::STRING, 10, 2)),
    manager_id NUMBER(38,0) AS (TRY_TO_NUMBER($1:c10::STRING)),
    department_id NUMBER(38,0) AS (TRY_TO_NUMBER($1:c11::STRING))
)
LOCATION = @secure_s3_event_stage
AUTO_REFRESH = TRUE
FILE_FORMAT = (FORMAT_NAME = 'csv_format');

SHOW EXTERNAL TABLES like 'ext_employee_events';

SELECT * FROM ext_employee_events;  --50

create or replace materialized view EXT_VW as
SELECT * FROM ext_employee_events;

select * from ext_vw;


-- EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID

