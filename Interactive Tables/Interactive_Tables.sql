CREATE OR REPLACE INTERACTIVE TABLE customer_orders
cluster by (o_custkey)
-- warehouse=COMPUTE_WH
as
select 
o_custkey,
count(O_ORDERKEY) as total_orders,
sum(o_totalprice) as cumulative_sum,
max(o_orderdate) as latest_order_date
from snowflake_sample_data.tpch_sf1000.orders
group by 1;



create or replace warehouse my_itr_warehouse
 MIN_CLUSTER_COUNT = 1                       
  MAX_CLUSTER_COUNT = 5 
  warehouse_size='XSMALL'
warehouse_type=INTERACTIVE;

drop warehouse my_itr_warehouse;

ALTER WAREHOUSE my_itr_warehouse ADD TABLES(customer_orders);

ALTER WAREHOUSE my_itr_warehouse RESUME;


SELECT * FROM customer_orders WHERE o_custkey=1234567; --162ms

update customer_orders set o_custkey=1234567890 WHERE o_custkey=1234567;


select 
o_custkey,
count(O_ORDERKEY) as total_orders,
sum(o_totalprice) as cumulative_sum,
max(o_orderdate) as latest_order_date
from snowflake_sample_data.tpch_sf1000.orders
where o_custkey=1234567
group by 1;   --- 17sec 

