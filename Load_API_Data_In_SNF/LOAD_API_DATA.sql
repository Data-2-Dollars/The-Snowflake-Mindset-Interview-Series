USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

CREATE OR REPLACE NETWORK RULE api_network_rule
MODE = EGRESS
TYPE = HOST_PORT
VALUE_LIST = ('<public>,<private>')


-- https://github.com/public-apis/public-apis

--- USE BELOW WHEN ITS PUBLIC API
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION api_external_integration
ALLOWED_NETWORK_RULES = (api_network_rule)
ENABLED= TRUE;

----SECRET WHICH IS REQD FOR PRIVATE API
CREATE OR REPLACE SECRET my_api_secret 
TYPE = GENERIC_STRING
SECRET_STRING = 'api_key/beareda token'

--- USE BELOW WHEN ITS PRIVATE API
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION api_external_integration
ALLOWED_NETWORK_RULES = (api_network_rule)
ALLOWED_AUTHENTICATION METHODS = (my_api_secret)
ENABLED= TRUE;


CREATE OR REPLACE TABLE raw_api_data (
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    data VARIANT
);



----SP EXAMPLE FOR PUBLIC API
CREATE OR REPLACE PROCEDURE fetch_and_load_api_data()
RETURN STRING
LANGUAGE = PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python','requests')
EXTERNAL_ACCESS_INTEGRATION = (api_external_integration)
HANDLER = 'main'
EXECUTE AS CALLER
AS
$$
import requests

def main(session):
    url = ''
    response = requests.get(url)
    if response.status_code == 200:
            api_json=response.json()
            for jas in api_json:
            session.sql(
'insert into raw_api_data(data) Select PARSE_JSON(?),
 params = [str(jas).replace("'",'"')]
            ).collect()
    return f"Data fetched and loaded successfully"        
    else:
        return f"Failed to fetch data, HTTP Status: {response.status_code}"
$$;


--SP example for private api

CREATE OR REPLACE PROCEDURE fetch_and_load_api_data()
RETURN STRING
LANGUAGE = PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python','requests')
EXTERNAL_ACCESS_INTEGRATION = (api_external_integration)
HANDLER = 'main'
EXECUTE AS CALLER
AS
$$
import requests

def main(session):
    api_token = _snowflake.get_generic_secret_string('my_api_secret')
    headers ={
        'Authorization': f'Bearer {api_token}',
        "Accept":"application/json"
    }
    url = ''
    response = requests.get(url,headers=headers)
    if response.status_code == 200:
            api_json=response.json()
            for jas in api_json:
            session.sql(
'insert into raw_api_data(data) Select PARSE_JSON(?),
 params = [str(jas).replace("'",'"')]
            ).collect()
    return f"Data fetched and loaded successfully"        
    else:
        return f"Failed to fetch data, HTTP Status: {response.status_code}"
$$;


call fetch_and_load_api_data();


