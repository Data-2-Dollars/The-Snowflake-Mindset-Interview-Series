CREATE OR REPLACE HYBRID TABLE customers (
    customer_id   BIGINT NOT NULL,
    email         VARCHAR(100) NOT NULL,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    signup_date   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT pk_customer_id PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email UNIQUE (email)
);

CREATE OR REPLACE HYBRID TABLE orders (
    order_id        VARCHAR(64) NOT NULL,
    customer_id     BIGINT NOT NULL,
    order_status    VARCHAR(20) NOT NULL,
    order_total     NUMBER(12,2),
    created_at      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT pk_order_id PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer_id 
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_orders_status (order_status)
);


INSERT INTO customers (customer_id, email, first_name, last_name)
VALUES (1002, 'alex@example.com', 'Alexander', 'Great');   ----Yes because this is first


INSERT INTO customers (customer_id, email, first_name, last_name)
VALUES (1002, 'bob@example.com', 'Alexander', 'Great');   ---duplicate attempt



INSERT INTO customers (customer_id, email, first_name, last_name)
VALUES (1003, 'alex@example.com', 'Alexander', 'Great');   ---error violating unique key constriant


INSERT INTO orders (order_id, customer_id, order_status, order_total)
VALUES ('ORD-001', 9999, 'PENDING', 250.00);   --refrential integrity constraint violation


INSERT INTO orders (order_id, customer_id, order_status, order_total)
VALUES ('ORD-001', 1002, 'PENDING', 250.00);   --Success 
