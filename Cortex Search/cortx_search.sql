CREATE DATABASE IF NOT EXISTS cortex_search_tutorial_db;

CREATE OR REPLACE WAREHOUSE cortex_search_tutorial_wh WITH
     WAREHOUSE_SIZE='X-SMALL'
     AUTO_SUSPEND = 120
     AUTO_RESUME = TRUE
     INITIALLY_SUSPENDED=TRUE;

drop warehouse cortex_search_tutorial_wh;
CREATE OR REPLACE CORTEX SEARCH SERVICE cortex_search_tutorial_db.public.airbnb_svc
ON listing_text
ATTRIBUTES room_type, amenities
WAREHOUSE = cortex_search_tutorial_wh
TARGET_LAG = '1 hour'
AS
    SELECT
        room_type,
        amenities,
        price,
        cancellation_policy,
        ('Summary\n\n' || summary || '\n\n\nDescription\n\n' || description || '\n\n\nSpace\n\n' || space) as listing_text
    FROM
    cortex_search_tutorial_db.public.airbnb_listings;

-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/tutorials/cortex-search-tutorial-1-search#step-2-load-the-data-into-snowflake
