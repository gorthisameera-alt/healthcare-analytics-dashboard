-- ============================================================
-- Healthcare Operations & Patient Flow Analytics
-- File: 04_staffing_analysis.sql
-- Purpose:
-- Analyze staffing levels, understaffing patterns,
-- shift performance, monthly staffing trends,
-- and workload relative to staffing capacity.
-- ============================================================

USE healthcare_analytics;


-- ============================================================
-- 1. DEPARTMENT STAFFING PERFORMANCE
-- Compares scheduled staffing, actual staffing,
-- staffing variance, and total staffing hours by department.
-- ============================================================

SELECT
    d.department_name,
    SUM(s.scheduled_staff) AS scheduled_staff,
    SUM(s.actual_staff) AS actual_staff,
    SUM(s.actual_staff) - SUM(s.scheduled_staff) AS staffing_variance,
    SUM(s.staffing_hours) AS total_staffing_hours
FROM staffing s
INNER JOIN departments d
    ON s.department_id = d.department_id
GROUP BY d.department_name
ORDER BY staffing_variance;


-- ============================================================
-- 2. UNDERSTAFFING BY DEPARTMENT
-- Calculates the number and percentage of shifts
-- where actual staffing was below scheduled staffing.
-- ============================================================

SELECT
    d.department_name,
    COUNT(*) AS total_shifts,
    SUM(
        CASE
            WHEN s.actual_staff < s.scheduled_staff THEN 1
            ELSE 0
        END
    ) AS understaffed_shifts,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN s.actual_staff < s.scheduled_staff THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS understaffed_percentage
FROM staffing s
INNER JOIN departments d
    ON s.department_id = d.department_id
GROUP BY d.department_name
ORDER BY understaffed_percentage DESC;


-- ============================================================
-- 3. STAFFING PERFORMANCE BY SHIFT
-- Compares scheduled and actual staffing across shifts.
-- ============================================================

SELECT
    shift,
    SUM(scheduled_staff) AS scheduled_staff,
    SUM(actual_staff) AS actual_staff,
    SUM(actual_staff) - SUM(scheduled_staff) AS staffing_variance,
    SUM(staffing_hours) AS total_staffing_hours
FROM staffing
GROUP BY shift
ORDER BY shift;


-- ============================================================
-- 4. MONTHLY STAFFING TREND
-- Tracks staffing levels and staffing hours over time.
-- ============================================================

SELECT
    DATE_FORMAT(staffing_date, '%Y-%m') AS staffing_month,
    SUM(scheduled_staff) AS scheduled_staff,
    SUM(actual_staff) AS actual_staff,
    SUM(actual_staff) - SUM(scheduled_staff) AS staffing_variance,
    SUM(staffing_hours) AS total_staffing_hours
FROM staffing
GROUP BY DATE_FORMAT(staffing_date, '%Y-%m')
ORDER BY staffing_month;


-- ============================================================
-- 5. WORKLOAD VS STAFFING CAPACITY
-- Aggregates encounters and staffing at the daily department
-- level before joining, avoiding duplicate multiplication.
-- Calculates encounters handled per staffing hour.
-- ============================================================

WITH daily_encounters AS (
    SELECT
        DATE(admission_datetime) AS activity_date,
        department_id,
        COUNT(*) AS total_encounters
    FROM encounters
    GROUP BY
        DATE(admission_datetime),
        department_id
),

daily_staffing AS (
    SELECT
        staffing_date,
        department_id,
        SUM(staffing_hours) AS total_staffing_hours
    FROM staffing
    GROUP BY
        staffing_date,
        department_id
)

SELECT
    d.department_name,
    SUM(e.total_encounters) AS total_encounters,
    SUM(s.total_staffing_hours) AS total_staffing_hours,
    ROUND(
        SUM(e.total_encounters) /
        NULLIF(SUM(s.total_staffing_hours), 0),
        3
    ) AS encounters_per_staff_hour
FROM daily_encounters e
INNER JOIN daily_staffing s
    ON e.activity_date = s.staffing_date
    AND e.department_id = s.department_id
INNER JOIN departments d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY encounters_per_staff_hour DESC;
