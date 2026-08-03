CREATE OR REPLACE STORAGE INTEGRATION s3_dir_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::6420721192:role/snf'
  STORAGE_ALLOWED_LOCATIONS = ('s3://my-snowflake-data-lake');

  desc integration s3_dir_integration;


CREATE OR REPLACE STAGE s3_unstructured_stage
URL = 's3://my-snowflake-data-lake'
STORAGE_INTEGRATION = s3_dir_integration
DIRECTORY = (
ENABLE = TRUE
AUTO_REFRESH =FALSE
);

-- create or replace table demo_tbl
-- list @s3_unstructured_stage;  --eRROR
create or replace table demo_tbl_dir as
SELECT * FROM DIRECTORY(@s3_unstructured_stage);


select * from demo_tbl_dir;


SELECT RELATIVE_PATH,
GET_PRESIGNED_URL(@s3_unstructured_stage,RELATIVE_PATH,1800) AS TEMP_DOWNLOAD_LINK,
BUILD_SCOPED_FILE_URL(@s3_unstructured_stage,RELATIVE_PATH),  --SESSION BOUND UPTO 24HOUR
BUILD_STAGE_FILE_URL(@s3_unstructured_stage,RELATIVE_PATH)   ---ITS LIKE A PERMANT TABLE
FROM DIRECTORY(@s3_unstructured_stage);






