
-- SQL Script for Project
-- Target Database: PostgreSQL

===============================================================
=== Cross-Sport Overlap Percentage Matrix Analysis ===
===============================================================

-- Define the expected major sport categories from your simulation for the matrix columns
-- ** ADJUST THIS LIST AS NEEDED **
-- Example list: ('Football', 'Boxing', 'F1', 'NFL', 'Darts')

WITH
-- Create a distinct list of users and the sports they watched
UserSportPairs AS (
    SELECT DISTINCT
        vl.user_id,
        e.sport_category
    FROM
        viewing_log vl
    JOIN
        events e ON vl.event_id = e.event_id
    WHERE e.sport_category IN ('Football', 'Boxing', 'F1', 'NFL', 'Darts')
),
-- Calculate the total number of unique viewers for each sport (denominator)
SportTotalViewers AS (
    SELECT
        sport_category,
        COUNT(DISTINCT user_id) AS total_viewers
    FROM
        UserSportPairs
    GROUP BY
        sport_category
),
-- Generate all combinations of (user, sport_a, sport_b) where a user watched both
UserSportCombinations AS (
    SELECT
        usp_a.user_id,
        usp_a.sport_category AS sport_a, -- The 'row' sport
        usp_b.sport_category AS sport_b  -- The 'column' sport
    FROM
        UserSportPairs usp_a
    JOIN
        UserSportPairs usp_b ON usp_a.user_id = usp_b.user_id
)
-- Final aggregation to build the matrix
SELECT
    stv.sport_category AS "Sport A (Rows)",
    stv.total_viewers AS "Total Viewers of Sport A",

    -- === Columns for Sport B (Formatted as Percentage Strings) ===

    -- Format % of 'Sport A' viewers who also watched 'Football'
    -- Handle potential division by zero if total_viewers could somehow be 0
    CASE
        WHEN stv.total_viewers > 0 THEN
            ROUND(
                CAST(COUNT(DISTINCT usc.user_id) FILTER (WHERE usc.sport_b = 'Football') AS DECIMAL) * 100.0 / stv.total_viewers,
            2)::TEXT || '%'
        ELSE 'N/A' -- Or '0.00%' or NULL depending on preference
    END AS "% Also Watched Football",

    -- Format % of 'Sport A' viewers who also watched 'Boxing'
    CASE
        WHEN stv.total_viewers > 0 THEN
             ROUND(
                 CAST(COUNT(DISTINCT usc.user_id) FILTER (WHERE usc.sport_b = 'Boxing') AS DECIMAL) * 100.0 / stv.total_viewers,
            2)::TEXT || '%'
        ELSE 'N/A'
    END AS "% Also Watched Boxing",

    -- Format % of 'Sport A' viewers who also watched 'F1'
    CASE
        WHEN stv.total_viewers > 0 THEN
            ROUND(
                CAST(COUNT(DISTINCT usc.user_id) FILTER (WHERE usc.sport_b = 'F1') AS DECIMAL) * 100.0 / stv.total_viewers,
            2)::TEXT || '%'
        ELSE 'N/A'
    END AS "% Also Watched F1",

    -- Format % of 'Sport A' viewers who also watched 'NFL'
    CASE
        WHEN stv.total_viewers > 0 THEN
             ROUND(
                 CAST(COUNT(DISTINCT usc.user_id) FILTER (WHERE usc.sport_b = 'NFL') AS DECIMAL) * 100.0 / stv.total_viewers,
            2)::TEXT || '%'
        ELSE 'N/A'
    END AS "% Also Watched NFL",

    -- Format % of 'Sport A' viewers who also watched 'Darts'
    CASE
        WHEN stv.total_viewers > 0 THEN
             ROUND(
                 CAST(COUNT(DISTINCT usc.user_id) FILTER (WHERE usc.sport_b = 'Darts') AS DECIMAL) * 100.0 / stv.total_viewers,
            2)::TEXT || '%'
        ELSE 'N/A'
    END AS "% Also Watched Darts"

    -- Add more columns here if you have other sport categories in your data,
    -- following the same pattern (CASE WHEN... ROUND(...)::TEXT || '%' ELSE 'N/A' END AS "...")

FROM
    SportTotalViewers stv
LEFT JOIN
    UserSportCombinations usc ON stv.sport_category = usc.sport_a
GROUP BY
    stv.sport_category, stv.total_viewers
ORDER BY
    stv.sport_category;
