CREATE OR REPLACE DATABASE file_format_sandbox;
CREATE OR REPLACE SCHEMA file_formats;

create or replace file format csv_demo
type='csv'
FIELD_DELIMITER=','
FIELD_OPTIONALLY_ENCLOSED_BY='"'
skip_header=1
trim_space=True;


create or replace file format json_demo
type='json'
STRIP_OUTER_ARRAY=TRUE
;

create or replace file format AVRO_demo
type='AVRO'
;

create or replace file format PARQUET_demo
type='PARQUET'
BINARY_AS_TEXT=TRUE
;



create or replace file format XML_demo
type='XML'
PRESERVE_SPACE=FALSE
STRIP_OUTER_ELEMENT=TRUE
;


CREATE OR REPLACE TABLE titanic_passengers (
    PassengerId VARCHAR,
    Survived    VARCHAR,
    Pclass      VARCHAR,
    Name        VARCHAR,
    Sex         VARCHAR,
    Age         VARCHAR,
    SibSp       VARCHAR,
    Parch       VARCHAR,
    Ticket      VARCHAR,
    Fare        VARCHAR,
    Cabin       VARCHAR,
    Embarked    VARCHAR
);


CREATE OR REPLACE TABLE JSON_DEMO (
    MY_COL VARIANT
);


CREATE OR REPLACE TABLE AVRO_DEMO (
    MY_COL VARIANT
);


CREATE OR REPLACE TABLE ORC_DEMO (
    MY_COL VARIANT
);

CREATE OR REPLACE TABLE PARQUET_DEMO (
    MY_COL VARIANT
);

CREATE OR REPLACE TABLE XML_DEMO (
    MY_COL VARIANT
);


select * from JSON_DEMO;

