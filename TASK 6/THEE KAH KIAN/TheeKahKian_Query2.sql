-- Query2: Promotion Campaign Average Sales Report
-- Purpose: This query allows management to know whether the performance of promotional campaigns has met expectations.
-- Set formatting options
SET LINESIZE 120
SET PAGESIZE 35

-- Set date format for the session
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

-- Prompt for user input
ACCEPT v_menu_id NUMBER FORMAT '9999' PROMPT 'Enter menu campaign promotion id: '
ACCEPT v_expectedSales NUMBER FORMAT '9999.99' PROMPT 'Enter expected sales per day (RM): '

-- Define column formatting
COLUMN menu_promotion_campaign_id FORMAT 9999 HEADING "Menu Promotion Campaign ID"
COLUMN date_difference_in_days FORMAT 9999 HEADING "Campaign Duration(day)"
COLUMN Total_Sales FORMAT 99990.90 HEADING "Total Sales(RM)"
COLUMN average_Sales FORMAT 99990.90 HEADING "Avg Sales Per Day(RM)"
COLUMN performance FORMAT A30 HEADING "PERFORMANCE RATIO"

-- Define report title
TTITLE 'Promotion Campaign Average Sales Report  ' _DATE -
CENTER 'Page No: ' FORMAT 999 SQL.PNO SKIP 2
-- Enable report breaks
BREAK ON REPORT

-- Common Table Expressions (CTEs) for Total Sales and Campaign Duration
WITH TotalSales AS (
    SELECT pp.menu_promotion_campaign_id, SUM(p.payment_amount) AS Total_Sales
    FROM payment p
    JOIN promo_payment pp ON p.payment_id = pp.payment_id
    GROUP BY pp.menu_promotion_campaign_id
),
CampaignPeriod AS (
    SELECT mpc.menu_promotion_campaign_id, 
           (TO_DATE(mpc.campaign_end_date, 'DD-MON-YYYY') - TO_DATE(mpc.campaign_start_date, 'DD-MON-YYYY')) AS date_difference_in_days
    FROM menu_promotion_campaign mpc
    WHERE mpc.menu_promotion_campaign_id IN (SELECT menu_promotion_campaign_id FROM promo_payment)
)
-- Main query to calculate and report campaign performance
SELECT
    ts.menu_promotion_campaign_id,
    ts.Total_Sales,
    cp.date_difference_in_days,
    (ts.Total_Sales / cp.date_difference_in_days) AS average_Sales,
    CASE 
        WHEN (ts.Total_Sales / cp.date_difference_in_days) > &v_expectedSales THEN 'Outperformed'
        WHEN (ts.Total_Sales / cp.date_difference_in_days) < &v_expectedSales THEN 'Below performance'
        ELSE 'Normal'
    END performance
FROM TotalSales ts
CROSS JOIN CampaignPeriod cp
WHERE ts.menu_promotion_campaign_id = cp.menu_promotion_campaign_id
AND ts.menu_promotion_campaign_id = &v_menu_id
ORDER BY ts.menu_promotion_campaign_id;

-- Clear formatting options, breaks, and computes
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
-- Turn off the report title
TTITLE OFF
