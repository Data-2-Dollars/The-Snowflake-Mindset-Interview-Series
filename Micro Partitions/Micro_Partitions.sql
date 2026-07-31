CREATE DATABASE IF NOT EXISTS partition_demo_db;
USE DATABASE partition_demo_db;
USE SCHEMA PUBLIC;


CREATE WAREHOUSE IF NOT EXISTS demo_wh WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60;
USE WAREHOUSE demo_wh;

CREATE OR REPLACE TABLE sales_data (
    region          VARCHAR(100),
    country         VARCHAR(100),
    item_type       VARCHAR(100),
    sales_channel   VARCHAR(50),
    order_priority  VARCHAR(5),
    order_date      DATE,
    order_id        NUMBER(38,0),
    ship_date       DATE,
    units_sold      NUMBER(38,0),
    unit_price      NUMBER(38,2),
    unit_cost       NUMBER(38,2),
    total_revenue   NUMBER(38,2),
    total_cost      NUMBER(38,2),
    total_profit    NUMBER(38,2)
);

select * from sales_data where Region='Sub-Saharan Africa' and ITEM_TYPE='Meat';

SELECT SYSTEM$CLUSTERING_INFORMATION('sales_data','(region,order_date)');

ALTER TABLE SALES_dATA CLUSTER BY (region,order_date);

select * from sales_data where region='Asia' and sales_channel='Online';

SELECT table_name, clustering_key, auto_clustering_on
FROM information_schema.tables
WHERE table_name = 'SALES_DATA';
