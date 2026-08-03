create or replace catalog integration iceberg_object_store_catalog
CATALOG_SOURCE = OBJECT_STORE
TABLE_FORMAT = ICEBERG
ENABLED=TRUE;

-- CREATE OR REPLACE EXTERNAL VOLUME s3_iceberg_volume
-- STORAGE_LOCATIONS = (
--     (
--         NAME = 'my-s3-iceberg-storage'
--         STORAGE_PROVIDER = 'S3'
--         STORAGE_BASE_URL = 's3://snowflakedemoutube'
--         STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::641192:role/SNF_DEMO'
--     )
-- )
-- ALLOW_WRITES = TRUE;

CREATE OR REPLACE ICEBERG TABLE read_existing_s3_iceberg
EXTERNAL_VOLUME='s3_iceberg_volume'
CATALOG = 'iceberg_object_store_catalog'
METADATA_FILE_PATH='employees.RIvBuY9I/metadata/00002-a5249253-43e2-4881-87ee-f3fd51da5073.metadata.json';  --CHANGE UR OWN


SELECT * FROM read_existing_s3_iceberg;
