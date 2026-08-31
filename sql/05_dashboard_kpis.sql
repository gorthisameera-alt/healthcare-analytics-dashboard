-- ============================================================
-- Healthcare Operations & Patient Flow Analytics
-- File: 05_dashboard_kpis.sql
-- Purpose:
-- Create and validate the core operational KPIs that will
-- later be used in the Power BI dashboard.
-- ============================================================

USE healthcare_analytics;


-- ============================================================
-- 1. PATIENT FLOW KPIs
-- ============================================================

SELECT
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(length_of_stay_hours), 2) AS avg_los_hours
FROM encounters;


-- ============================================================
-- 2. OVERALL STAFFING KPIs
-- ============================================================

SELECT
    SUM(scheduled_staff) AS total_scheduled_staff,
    SUM(actual_staff) AS total_actual_staff,
    SUM(actual_staff) - SUM(scheduled_staff) AS staffing_variance,
    SUM(staffing_hours) AS total_staffing_hours
FROM staffing;


-- ============================================================
-- 3. UNDERSTAFFING KPIs
-- ============================================================

SELECT
    COUNT(*) AS total_shifts,
    SUM(
        CASE
            WHEN actual_staff < scheduled_staff THEN 1
            ELSE 0
        END
    ) AS understaffed_shifts,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN actual_staff < scheduled_staff THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS understaffed_percentage
FROM staffing;


-- ============================================================
-- 4. WORKLOAD PRODUCTIVITY KPI
-- Aggregate both fact tables before joining to prevent
-- duplicate multiplication.
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
    AND e.department_id = s.department_id;


-- ============================================================
-- 5. DEPARTMENT-LEVEL DASHBOARD KPIs
-- Provides department-level encounter volume and LOS.
-- ============================================================

SELECT
    d.department_name,
    COUNT(e.encounter_id) AS total_encounters,
    COUNT(DISTINCT e.patient_id) AS unique_patients,
    ROUND(AVG(e.length_of_stay_hours), 2) AS avg_los_hours
FROM departments d
LEFT JOIN encounters e
    ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY total_encounters DESC;
