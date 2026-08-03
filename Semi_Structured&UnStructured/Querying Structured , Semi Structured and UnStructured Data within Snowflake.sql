-- Step 1: Create JSON file format
CREATE OR REPLACE FILE FORMAT my_json_format
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;

-- Step 2: Create stage
CREATE OR REPLACE STAGE my_json_stage;

-- Step 3: List files in stage (after uploading flowers.json)
LIST @my_json_stage;

-- Step 4: Create raw table with VARIANT column
CREATE OR REPLACE TABLE raw_json_data (
    json_content VARIANT
);

-- Step 5: Copy data from stage to raw table
COPY INTO raw_json_data
FROM @my_json_stage/flowers.json
FILE_FORMAT = (FORMAT_NAME = 'my_json_format');

-- Step 6: Query raw JSON table
SELECT * FROM raw_json_data;

-- Step 7: Create final structured table
CREATE OR REPLACE TABLE flowers (
    petal_length FLOAT,
    sepal_length FLOAT,
    sepal_width FLOAT,
    petal_width FLOAT,
    variety STRING
);

-- Step 8: Parse and insert JSON elements into target table
INSERT INTO flowers
SELECT 
    json_content:"petal.length"::FLOAT,
    json_content:"sepal.length"::FLOAT,
    json_content:"sepal.width"::FLOAT,
    json_content:"petal.width"::FLOAT,
    json_content:"variety"::STRING
FROM raw_json_data;

-- Step 9: Query structured flowers table
SELECT * FROM flowers;




-- Step 1: Create XML file format
CREATE OR REPLACE FILE FORMAT my_xml_format
  TYPE = 'XML';

-- Step 2: Create stage
CREATE OR REPLACE STAGE my_xml_stage;

-- Step 3: List files in XML stage (after uploading books.xml)
LIST @my_xml_stage;

-- Step 4: Create raw table
CREATE OR REPLACE TABLE raw_books_xml (
    xml_content VARIANT
);

-- Step 5: Copy XML file into raw table
COPY INTO raw_books_xml
FROM @my_xml_stage/books.xml
FILE_FORMAT = (FORMAT_NAME = 'my_xml_format');

-- Step 6: Query raw XML data
SELECT * FROM raw_books_xml;

-- Step 7: Create target relational table
CREATE OR REPLACE TABLE books (
    book_id STRING,
    author STRING,
    title STRING,
    genre STRING,
    price FLOAT,
    publish_date DATE,
    description STRING
);

-- Step 8: Flatten XML elements and insert into structured table
INSERT INTO books
SELECT 
    GET(f.value, '@id')::STRING AS book_id,
    XMLGET(f.value, 'author'):"$"::STRING AS author,
    XMLGET(f.value, 'title'):"$"::STRING AS title,
    XMLGET(f.value, 'genre'):"$"::STRING AS genre,
    XMLGET(f.value, 'price'):"$"::FLOAT AS price,
    XMLGET(f.value, 'publish_date'):"$"::DATE AS publish_date,
    XMLGET(f.value, 'description'):"$"::STRING AS description
FROM raw_books_xml,
LATERAL FLATTEN(input => xml_content:"$") f;

-- Step 9: Query final books table
SELECT * FROM books;


-- Step 1: Create Parquet file format
CREATE OR REPLACE FILE FORMAT my_parquet_format
  TYPE = 'PARQUET';

-- Step 2: Create stage
CREATE OR REPLACE STAGE my_parquet_stage;

-- Step 3: List stage files (after uploading empty_cars.parquet)
LIST @my_parquet_stage;

-- Step 4: Create raw VARIANT table
CREATE OR REPLACE TABLE raw_parquet_data (
    parquet_content VARIANT
);

-- Step 5: Load Parquet data into raw table
COPY INTO raw_parquet_data
FROM @my_parquet_stage/empty_cars.parquet
FILE_FORMAT = (FORMAT_NAME = 'my_parquet_format');

-- Step 6: Query raw table
SELECT * FROM raw_parquet_data;

-- Step 7: Create structured target table
CREATE OR REPLACE TABLE empty_cars (
    car_model STRING,
    mpg FLOAT,
    cyl INT,
    disp FLOAT,
    hp INT,
    drat FLOAT,
    wt FLOAT,
    qsec FLOAT,
    vs INT,
    am INT,
    gear INT,
    carb INT
);

-- Step 8: Insert extracted fields into target table
INSERT INTO empty_cars
SELECT 
    parquet_content:car_model::STRING,
    parquet_content:mpg::FLOAT,
    parquet_content:cyl::INT,
    parquet_content:disp::FLOAT,
    parquet_content:hp::INT,
    parquet_content:drat::FLOAT,
    parquet_content:wt::FLOAT,
    parquet_content:qsec::FLOAT,
    parquet_content:vs::INT,
    parquet_content:am::INT,
    parquet_content:gear::INT,
    parquet_content:carb::INT
FROM raw_parquet_data;

-- Step 9: Query final empty_cars table
SELECT * FROM empty_cars;



-- Step 1: Create stage with Directory Table enabled
CREATE OR REPLACE STAGE my_unstructured_stage
  DIRECTORY = (ENABLE = TRUE);

-- Step 2: Query metadata from Directory Table
SELECT 
    relative_path,
    size,
    last_modified,
    file_url
FROM DIRECTORY(@my_unstructured_stage);

-- Step 3: Generate scoped file URLs for temporary access
SELECT 
    relative_path,
    BUILD_SCOPED_FILE_URL(@my_unstructured_stage, relative_path) AS temporary_link
FROM DIRECTORY(@my_unstructured_stage);

-- Step 4: Create Python UDF to read and extract text from PDF files
CREATE OR REPLACE FUNCTION extract_pdf_text(file_path STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'pypdf')
HANDLER = 'read_pdf'
AS
$$
from pypdf import PdfReader
from snowflake.snowpark.files import SnowflakeFile

def read_pdf(file_path):
    text = ""
    with SnowflakeFile.open(file_path, 'rb') as f:
        reader = PdfReader(f)
        for page in reader.pages:
            text += page.extract_text() or ""
    return text
$$;

-- Step 5: Test text extraction on a single PDF file
SELECT extract_pdf_text(
    BUILD_SCOPED_FILE_URL(@my_unstructured_stage, 'invoice123.pdf')
);

-- Step 6: Process all stage PDFs into a structured table dynamically
CREATE OR REPLACE TABLE processed_invoices AS
SELECT 
    relative_path AS file_id,
    last_modified AS upload_date,
    extract_pdf_text(BUILD_SCOPED_FILE_URL(@my_unstructured_stage, relative_path)) AS content
FROM DIRECTORY(@my_unstructured_stage);

-- Step 7: Query processed invoices
SELECT * FROM processed_invoices;
