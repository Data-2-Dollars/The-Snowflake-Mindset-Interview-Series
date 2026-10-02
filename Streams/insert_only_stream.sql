-- Insert-Only streams are used specifically for External Tables or Iceberg Tables

-- 1. Create Insert-Only Stream on External Table
CREATE OR REPLACE STREAM strm_exts ON EXTERNAL TABLE ext_customer
INSERT_ONLY = TRUE;

SELECT * FROM ext_customer;
SELECT * FROM strm_exts;

-- 2. Refresh external table after uploading a file to S3
ALTER EXTERNAL TABLE ext_customer REFRESH;

-- 3. Query Stream data (Includes additional METADATA$FILENAME column)
SELECT * FROM ext_customer;
SELECT * FROM strm_exts;
