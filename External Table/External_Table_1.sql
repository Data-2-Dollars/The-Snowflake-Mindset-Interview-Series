CREATE OR REPLACE EXTERNAL TABLE ext_employee_events_partition (
    department_partition NUMBER(38,0) AS (
        TRY_TO_NUMBER(SPLIT_PART(SPLIT_PART(METADATA$FILENAME, '/', 2), '=', 2))
    ),
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
PARTITION BY (department_partition)
LOCATION = @secure_s3_event_stage
AUTO_REFRESH = TRUE
FILE_FORMAT = (FORMAT_NAME = 'csv_format');

-- SHOW EXTERNAL TABLES like 'ext_employee_events';

SELECT * FROM ext_employee_events_partition;

create or replace materialized view EXT_VW_part as
SELECT * FROM ext_employee_events_partition where department_partition is not null;

select * from EXT_VW_part;  --57 59


select * from TABLE(INFORMATION_SCHEMA.EXTERNAL_TABLE_FILES(
TABLE_NAME => 'ext_employee_events_partition'
));


select * from TABLE(INFORMATION_SCHEMA.EXTERNAL_TABLE_FILE_REGISTRATION_HISTORY(
TABLE_NAME => 'ext_employee_events_partition'
));

