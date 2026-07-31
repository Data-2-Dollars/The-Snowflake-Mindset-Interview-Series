CREATE OR REPLACE DATABASE constraint_demo_db;
CREATE OR REPLACE SCHEMA public;


CREATE OR REPLACE TABLE dim_customers (
    customer_id INT,
    customer_name VARCHAR(100) NOT NULL, -- Enforced
    email VARCHAR(150),
    CONSTRAINT pk_customer_id PRIMARY KEY (customer_id) -- Informational!
);

insert into dim_customers(customer_id)
values(99);

CREATE OR REPLACE TABLE fact_sales (
    sale_id INT,
    customer_id INT,
    amount DECIMAL(10,2),
    CONSTRAINT pk_sale_id PRIMARY KEY (sale_id), -- Informational!
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id) -- Informational!
);

INSERT INTO fact_sales (sale_id, customer_id, amount) 
VALUES (1, 998, 150.00);

SELECT * FROM fact_sales;


ALTER TABLE fact_sales ADD CONSTRAINT check_positive_amount CHECK (amount > 0) ENABLE NOVALIDATE;


INSERT INTO fact_sales (sale_id, customer_id, amount) 
VALUES (2, 999, -10.00);


