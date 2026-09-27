-- 1. Setup Database & Schema
CREATE DATABASE if not exists test_rap_db;
USE DATABASE test_rap_db;
USE SCHEMA public;

-- 2. Create Base Data Table
CREATE OR REPLACE TABLE staff_records (
    emp_id NUMBER,
    hire_date DATE,
    department VARCHAR(20),
    base_salary NUMBER,
    supervisor_id NUMBER
);

INSERT INTO staff_records VALUES
    (101, '2015-05-12', 'Sales', 55000, 104),
    (102, '2016-01-20', 'Engineering', 85000, 109),
    (103, '2019-11-05', 'Finance', 62000, 105),
    (104, '2017-03-15', 'Sales', 48000, 105),
    (105, '2020-08-10', 'Sales', 51000, 109),
    (106, '2018-02-01', 'Engineering', 95000, 104),
    (107, '2021-06-18', 'Finance', 45000, 101);

SELECT * FROM staff_records;

-- 3. Access Control Lookup Table
CREATE OR REPLACE TABLE role_dept_mapping (
    mapped_role STRING,
    allowed_dept STRING
);

INSERT INTO role_dept_mapping VALUES
    ('ROLE_SALES_MGR', 'Sales'),
    ('ROLE_ENG_MGR', 'Engineering'),
    ('ROLE_FIN_MGR', 'Finance');

SELECT * FROM role_dept_mapping;

CREATE OR REPLACE ROW ACCESS POLICY rap_department_filter AS (dept_val VARCHAR) 
RETURNS BOOLEAN ->
    CURRENT_ROLE() = 'ACCOUNTADMIN'
    OR EXISTS (
        SELECT 1 
        FROM role_dept_mapping
        WHERE mapped_role = CURRENT_ROLE()
          AND allowed_dept = dept_val
    );


ALTER TABLE staff_records 
    ADD ROW ACCESS POLICY rap_department_filter ON (department);


-- 5. Role and Grant Setup
CREATE OR REPLACE ROLE ROLE_SALES_MGR;
CREATE OR REPLACE ROLE ROLE_ENG_MGR;
CREATE OR REPLACE ROLE ROLE_FIN_MGR;


GRANT USAGE ON WAREHOUSE compute_wh TO ROLE ROLE_SALES_MGR;
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE ROLE_ENG_MGR;
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE ROLE_FIN_MGR;

GRANT USAGE ON DATABASE test_rap_db TO ROLE ROLE_SALES_MGR;
GRANT USAGE ON DATABASE test_rap_db TO ROLE ROLE_ENG_MGR;
GRANT USAGE ON DATABASE test_rap_db TO ROLE ROLE_FIN_MGR;

GRANT USAGE ON SCHEMA test_rap_db.public TO ROLE ROLE_SALES_MGR;
GRANT USAGE ON SCHEMA test_rap_db.public TO ROLE ROLE_ENG_MGR;
GRANT USAGE ON SCHEMA test_rap_db.public TO ROLE ROLE_FIN_MGR;

GRANT SELECT ON TABLE test_rap_db.public.staff_records TO ROLE ROLE_SALES_MGR;
GRANT SELECT ON TABLE test_rap_db.public.staff_records TO ROLE ROLE_ENG_MGR;
GRANT SELECT ON TABLE test_rap_db.public.staff_records TO ROLE ROLE_FIN_MGR;


-- 6. User Provisioning
CREATE OR REPLACE USER user_sales PASSWORD = 'Password123!';
GRANT ROLE ROLE_SALES_MGR TO USER user_sales;

CREATE OR REPLACE USER user_fin PASSWORD = 'Password123!';
GRANT ROLE ROLE_FIN_MGR TO USER user_fin;

CREATE OR REPLACE USER user_eng PASSWORD = 'Password123!';
GRANT ROLE ROLE_ENG_MGR TO USER user_eng;


select * from staff_records;

DROP USER user_eng;
DROP USER user_fin;
DROP USER user_sales;

DROP ROLE ROLE_SALES_MGR;
DROP ROLE ROLE_ENG_MGR;
DROP ROLE ROLE_FIN_MGR;

