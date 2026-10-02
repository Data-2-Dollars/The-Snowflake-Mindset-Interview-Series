-- 1. Create table and enable Change Tracking
CREATE OR REPLACE TABLE accounts (
    account_id INT,
    holder STRING,
    balance NUMBER(10,2)
);

ALTER TABLE accounts SET CHANGE_TRACKING = TRUE;

-- 2. Round 1: Insert and Track Timestamps
SET ts_start = CURRENT_TIMESTAMP();

INSERT INTO accounts VALUES 
(101, 'Chess', 500.00),
(102, 'Debug', 1200.00);

SET ts_after_insert = CURRENT_TIMESTAMP();

-- Query default changes between timestamps
SELECT account_id, holder, balance, METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID 
FROM accounts 
CHANGES(INFORMATION => DEFAULT) 
AT(TIMESTAMP => $ts_start) 
END(TIMESTAMP => $ts_after_insert);

-- 3. Round 2: Update, Delete, and Insert
UPDATE accounts SET balance = 750.00 WHERE account_id = 101;
DELETE FROM accounts WHERE account_id = 102;
INSERT INTO accounts VALUES (103, 'Charlie', 300.00);

SET ts_after_try = CURRENT_TIMESTAMP();

-- Query changes for Round 2
SELECT account_id, holder, balance, METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID 
FROM accounts 
CHANGES(INFORMATION => DEFAULT) 
AT(TIMESTAMP => $ts_after_insert) 
END(TIMESTAMP => $ts_after_try);

-- 4. Round 3: Immediate Insert and Delete in same session
INSERT INTO accounts VALUES (104, 'Tensor', 50.00);
DELETE FROM accounts WHERE account_id = 104;

SET ts_final = CURRENT_TIMESTAMP();

-- Query changes (Will show nothing because insert/delete happened before query point)
SELECT account_id, holder, balance, METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID 
FROM accounts 
CHANGES(INFORMATION => DEFAULT) 
AT(TIMESTAMP => $ts_after_try) 
END(TIMESTAMP => $ts_final);

-- 5. Query changes using Append-Only mode across full timeline
SELECT account_id, holder, balance, METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID 
FROM accounts 
CHANGES(INFORMATION => APPEND_ONLY) 
AT(TIMESTAMP => $ts_start) 
END(TIMESTAMP => $ts_final);
