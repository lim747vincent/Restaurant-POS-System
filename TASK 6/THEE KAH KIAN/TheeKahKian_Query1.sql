-- -- Set formatting options
-- SET linesize 120
-- SET pagesize 50

-- -- Set date format for the session
-- ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

-- -- Prompt for user input
-- ACCEPT v_startDate DATE FORMAT 'DD-MON-YYYY' PROMPT 'Enter start date (DD-MON-YYYY): '
-- ACCEPT v_endDate DATE FORMAT 'DD-MON-YYYY' PROMPT 'Enter end date (DD-MON-YYYY): '

-- Define column formatting
-- COL "ingredient id" FORMAT 9999 TRUNCATE HEADING "Ingredient ID"
-- COL "ingredient Name" FORMAT A40 TRUNCATE HEADING "Ingredient Name"
-- COL "Total Ingredient Used" FORMAT 9999 TRUNCATE HEADING "Total Ingredient Used"
-- COL "Total Cost" FORMAT 99990.99 TRUNCATE HEADING "Total Cost"

-- -- Define report title
-- TTITLE 'Total Ingredient Used In a Specific Time ' _DATE -
-- CENTER 'Page No: ' FORMAT 999 SQL.PNO SKIP 2
-- -- Enable report breaks
-- BREAK ON REPORT

-- -- Query for total ingredient usage
-- SELECT "Ingredient ID", "Ingredient Name", SUM(subquery.Total_Ingredient_Used * "Ingredient Price") AS "Total Cost"
-- FROM (
--     SELECT SUM(oi.order_item_quantity) AS "total_menu_item", 
--         mr.ingredient_id as "Ingredient ID",
--         i.ingredient_name as "Ingredient Name",
--         i.ingredient_price as "Ingredient Price",
--         SUM("total_menu_item") AS Total_Ingredient_Used,

--     FROM order_item oi
--     JOIN menu_item_ingredient_record mr ON oi.menu_item_id = mr.menu_item_id
--     JOIN order_form orf ON oi.order_form_id = orf.order_form_id
--     JOIN ingredient i ON mr.ingredient_id = i.ingredient_id
--     WHERE orf.order_date >= TO_DATE('&v_startDate', 'DD-MON-YYYY') AND orf.order_date <= TO_DATE('&v_endDate', 'DD-MON-YYYY')
--     AND orf.order_form_status = 'successful'
--     GROUP BY mr.ingredient_id, i.ingredient_name
-- ) subquery
-- GROUP BY "Ingredient ID", "Ingredient Name"
-- ORDER BY "Ingredient ID";

-- -- Clear formatting options
-- CLEAR COLUMNS
-- CLEAR BREAKS
-- CLEAR COMPUTES
-- -- Turn off the report title
-- TTITLE OFF

-- Query 1: Ingredient Used Summary
-- Purpose: To summarize the total number of ingredients used in a specific time period. This allows the management to predict how many ingredients need to be used in the future.
-- Set formatting options
SET LINESIZE 120
SET PAGESIZE 50

-- Set date format for the session
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

-- Prompt for user input
ACCEPT v_startDate DATE FORMAT 'DD-MON-YYYY' PROMPT 'Enter start date (DD-MON-YYYY): '
ACCEPT v_endDate DATE FORMAT 'DD-MON-YYYY' PROMPT 'Enter end date (DD-MON-YYYY): '

-- Define column formatting
COLUMN "Ingredient ID" FORMAT 9999 TRUNCATE HEADING "Ingredient ID"
COLUMN "Ingredient Name" FORMAT A40 TRUNCATE HEADING "Ingredient Name"
COLUMN "Total Ingredient Used" FORMAT 9999 TRUNCATE HEADING "Total Ingredient Used"
COLUMN "Total Cost" FORMAT 99990.99 TRUNCATE HEADING "Total Cost"

-- Define report title
TTITLE 'Total Ingredient Used In a Specific Time' _DATE -
CENTER 'Page No: ' FORMAT 999 SQL.PNO SKIP 2

-- Enable report breaks
BREAK ON REPORT

-- Query for total ingredient usage
SELECT "Ingredient ID", "Ingredient Name", SUM("total_menu_item") as "Total Ingredient Used"
FROM (
    SELECT SUM(oi.order_item_quantity) AS "total_menu_item",
        mr.ingredient_id as "Ingredient ID",
        i.ingredient_name as "Ingredient Name"
    FROM order_item oi
    JOIN menu_item_ingredient_record mr ON oi.menu_item_id = mr.menu_item_id
    JOIN order_form orf ON oi.order_form_id = orf.order_form_id
    JOIN ingredient i ON mr.ingredient_id = i.ingredient_id
    WHERE orf.order_date >= TO_DATE('&v_startDate', 'DD-MON-YYYY') AND orf.order_date <= TO_DATE('&v_endDate', 'DD-MON-YYYY')
    GROUP BY mr.ingredient_id, i.ingredient_name
) subquery
GROUP BY "Ingredient ID", "Ingredient Name"
ORDER BY "Ingredient ID";

-- Clear formatting options
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

-- Turn off the report title
TTITLE OFF
