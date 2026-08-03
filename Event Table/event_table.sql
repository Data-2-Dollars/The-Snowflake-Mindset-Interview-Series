select * from snowflake.telemetry.events;


create or replace event table cluster_telemetry_table;

alter ACCOUNT SET EVENT_TABLE='DEMO_DB.PUBLIC.cluster_telemetry_table';

SHOW PARAMETERS LIKE 'EVENT_TABLE' IN ACCOUNT;

ALTER ACCOUNT SET LOG_LEVEL = 'DEBUG';
ALTER ACCOUNT SET TRACE_LEVEL = 'ALWAYS';


ALTER DATABASE DEMO_DB SET LOG_LEVEL='DEBUG';
ALTER DATABASE DEMO_DB SET TRACE_LEVEL='ALWAYS';



CREATE OR REPLACE PROCEDURE emit_sql_telemetry(transaction_val NUMBER)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    invalid_transaction EXCEPTION (-20001, 'Invalid transaction amount detected.');
BEGIN
    SYSTEM$LOG_INFO('SQL Procedure initialized: Evaluating transaction amount validation.');
    
    IF (:transaction_val <= 0) THEN
        SYSTEM$LOG_ERROR('SQL operational constraint violated: Transaction value cannot be negative or zero.');
        RAISE invalid_transaction;
    END IF;
    
    SYSTEM$LOG_DEBUG('Transaction value checks passed. Proceeding with database operations.');
    RETURN 'SUCCESS';
END;
$$;


CALL emit_sql_telemetry(500);

BEGIN
CALL emit_sql_telemetry(-500);
EXCEPTION
WHEN OTHER THEN 
SELECT 'Caught exception Jaswinder bro...' AS status;
end;

CREATE OR REPLACE PROCEDURE emit_python_telemetry(user_email VARCHAR, access_score FLOAT)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python','snowflake-telemetry-python')
HANDLER = 'run_telemetry'
AS
$$
import logging
# Bind directly to the standard Python logging framework
logger = logging.getLogger("enterprise_python_logger")

def run_telemetry(session, user_email: str, access_score: float) -> str:
    logger.info(f"Python execution hook started for client identity context: {user_email}")
    
    if access_score < 0.4:
        logger.warning(f"High risk operational warning flagged for user: {user_email}. Access Score: {access_score}")
    else:
        logger.debug(f"User authentication score cleared normal limits: {access_score}")
        
    return f"Processed telemetry evaluation for {user_email}"
$$;




CALL emit_python_telemetry('compliance_officer@firm.com', 0.12);

select * from cluster_telemetry_table;



