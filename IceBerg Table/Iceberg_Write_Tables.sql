CREATE OR REPLACE EXTERNAL VOLUME s3_iceberg_volume
STORAGE_LOCATIONS = (
    (
        NAME = 'my-s3-iceberg-storage'
        STORAGE_PROVIDER = 'S3'
        STORAGE_BASE_URL = 's3://snowflakedemoutube'
        STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::6410721192:role/SNF_DEMO'
    )
)
ALLOW_WRITES = TRUE;

DESCRIBE EXTERNAL VOLUME s3_iceberg_volume;

CREATE OR REPLACE ICEBERG TABLE iceberg_employee_directory (
    employee_id INT,
    first_name STRING,
    last_name STRING,
    department STRING,
    salary NUMBER(10,2),
    hire_date DATE
)
CATALOG = 'SNOWFLAKE'                   
EXTERNAL_VOLUME = 's3_iceberg_volume'   
BASE_LOCATION = 'employees/';


INSERT INTO iceberg_employee_directory 
VALUES 
    (101, 'Alice', 'Smith', 'Engineering', 115000.00, '2026-03-15'::DATE),
    (102, 'Bob', 'Jones', 'Product', 105000.00, '2026-06-01'::DATE);

UPDATE iceberg_employee_directory
SET salary = 125000.00
WHERE employee_id = 101;


select * from table(information_schema.iceberg_table_files('iceberg_employee_directory'));


select * from iceberg_employee_directory;
