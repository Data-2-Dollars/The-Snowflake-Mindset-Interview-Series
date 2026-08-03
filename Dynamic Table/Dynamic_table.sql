CREATE OR REPLACE DATABASE snowflake_dynamic_lab;
CREATE OR REPLACE SCHEMA lab_schema;
USE DATABASE snowflake_dynamic_lab;
USE SCHEMA lab_schema;

-- Create base Department table
CREATE OR REPLACE TABLE department (
    dept_id INT,
    dept_name VARCHAR(50),
    location VARCHAR(50),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create base Employee table
CREATE OR REPLACE TABLE employee (
    emp_id INT,
    emp_name VARCHAR(50),
    role VARCHAR(50),
    salary INT,
    dept_id INT,
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Populate base data
INSERT INTO department (dept_id, dept_name, location) VALUES 
(10, 'Engineering', 'New York'),
(20, 'Data & Analytics', 'San Francisco');

INSERT INTO employee (emp_id, emp_name, role, salary, dept_id) VALUES 
(101, 'Alice', 'VP of Engineering', 200000, 10),
(201, 'Charlie', 'Lead Dev', 150000, 10),
(102, 'Bob', 'Data Director', 180000, 20),
(202, 'David', 'Data Scientist', 140000, 20);



CREATE OR REPLACE DYNAMIC TABLE dt_employee_directory
-- TARGET_LAG=    '1 MINUTE'
TARGET_LAG=DOWNSTREAM
WAREHOUSE=COMPUTE_WH
INITIALIZE=ON_SCHEDULE
REFRESH_MODE=AUTO
AS 
SELECT 
e.emp_id,
-- CURRENT_TIMESTAMP() AS TIMES,
      e.emp_name,
      e.role,
      e.salary,
      d.dept_name,
      d.location,
      e.updated_at AS employee_last_updated
from employee e
inner join (select * from department limit 1) d on e.dept_id=d.dept_id;


select * from dt_employee_directory;


SHOW DYNAMIC TABLES LIKE 'dt_%';


create or replace DYNAMIC TABLE dt_dept_financial_summary
target_lag='1 MINUTE'
WAREHOUSE=COMPUTE_WH
AS
SELECT 
DEPT_NAME,
COUNT(EMP_ID) AS HEAD_CNT,
SUM(SALARY) AS TOTAL_PAYROLL,
AVG(SALARY) AS AVG_CONCAT
FROM dt_employee_directory
GROUP BY 1;


SELECT * FROM dt_dept_financial_summary;



-- 1. Insert new structural components
INSERT INTO department (dept_id, dept_name, location) 
VALUES (30, 'DevOps Engineering', 'Remote');

-- 2. Hire an employee assigned to the new division
INSERT INTO employee (emp_id, emp_name, role, salary, dept_id) 
VALUES (301, 'Eve', 'Cloud Architect', 175000, 30);


