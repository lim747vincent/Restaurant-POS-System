-- Query: Gross Profit Report
-- Purpose: This query allows management to see the gross profit report within a specific period of time
-- Set formatting options
SET LINESIZE 120
SET PAGESIZE 35

-- Set date format for the session
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

-- Prompt for user input
ACCEPT v_startDate DATE FORMAT 'DD-MON-YYYY' PROMPT 'Enter start date (DD-MON-YYYY): '
ACCEPT v_endDate DATE FORMAT 'DD-MON-YYYY' PROMPT 'Enter end date (DD-MON-YYYY): '

-- Define column formatting
COLUMN order_form_id FORMAT 9999 TRUNCATE HEADING "Order Form ID"
COLUMN Total_Cost FORMAT 99990.90 TRUNCATE HEADING "Cost (RM)"
COLUMN Total_Sales FORMAT 99990.99 TRUNCATE HEADING "Sales (RM)"
COLUMN Gross_Profit FORMAT 99990.90 TRUNCATE HEADING "Gross Profit (RM)"

-- Define report title
TTITLE  'Gross Profit Report  ' _DATE -
'   Page No: ' FORMAT 999 SQL.PNO SKIP 2
-- Compute total sums and add a label
COMPUTE SUM LABEL 'Total : ' OF "Total_Cost", "Total_Sales", "Gross_Profit" ON REPORT;
-- Enable report breaks
BREAK ON REPORT;

-- Common Table Expressions (CTEs) for Total Cost and Total Sales
WITH TotalCost AS (
    SELECT oi.order_form_id, SUM(menu_item_costs.total_menu_item_cost * oi.order_item_quantity) AS Total_Cost
    FROM (
        SELECT miir.menu_item_id, SUM(i.ingredient_price) AS total_menu_item_cost
        FROM menu_item_ingredient_record miir
        JOIN ingredient i ON miir.ingredient_id = i.ingredient_id
        GROUP BY miir.menu_item_id
    ) menu_item_costs
    JOIN order_item oi ON menu_item_costs.menu_item_id = oi.menu_item_id
    JOIN order_form orf ON oi.order_form_id = orf.order_form_id
    WHERE orf.order_date BETWEEN TO_DATE('&v_startDate', 'DD-MON-YYYY') AND TO_DATE('&v_endDate', 'DD-MON-YYYY')
    GROUP BY oi.order_form_id
),
TotalSales AS (
    SELECT orf.order_form_id, SUM(p.payment_amount) AS total_sales
    FROM order_form orf
    JOIN payment p ON orf.payment_id = p.payment_id
    WHERE orf.order_date BETWEEN TO_DATE('&v_startDate', 'DD-MON-YYYY') AND TO_DATE('&v_endDate', 'DD-MON-YYYY')
    GROUP BY orf.order_form_id
)
-- Main query to calculate and report Gross Profit
SELECT tc.order_form_id, tc.Total_Cost, ts.total_sales, (ts.total_sales - tc.Total_Cost) AS Gross_Profit
FROM TotalCost tc
JOIN TotalSales ts ON tc.order_form_id = ts.order_form_id
ORDER BY tc.order_form_id;

-- Clear formatting options, breaks, and computes
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
-- Turn off the report title
TTITLE OFF

