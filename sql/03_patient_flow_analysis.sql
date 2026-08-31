-- ============================================================
-- Healthcare Operations & Patient Flow Analytics
-- File: 03_patient_flow_analysis.sql
-- Purpose:
-- Analyze encounter volume, patient utilization, length of stay,
-- admission patterns, discharge outcomes, and department trends.
-- ============================================================

USE healthcare_analytics;


-- ============================================================
-- 1. OVERALL PATIENT FLOW KPIs
-- Provides high-level encounter volume, unique patient count,
-- and average length of stay.
-- ============================================================

SELECT
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(length_of_stay_hours), 2) AS avg_length_of_stay_hours
FROM encounters;


-- ============================================================
-- 2. DEPARTMENT PERFORMANCE
-- Compares encounter volume, unique patients, and average
-- length of stay across departments and service types.
-- ============================================================

SELECT
    d.department_name,
    d.service_type,
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT e.patient_id) AS unique_patients,
    ROUND(AVG(e.length_of_stay_hours), 2) AS avg_los_hours
FROM encounters e
INNER JOIN departments d
    ON e.department_id = d.department_id
GROUP BY
    d.department_name,
    d.service_type
ORDER BY total_encounters DESC;


-- ============================================================
-- 3. MONTHLY PATIENT FLOW
-- Tracks encounter volume, unique patients, and average
-- length of stay over time.
-- ============================================================

SELECT
    DATE_FORMAT(admission_datetime, '%Y-%m') AS admission_month,
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(length_of_stay_hours), 2) AS avg_los_hours
FROM encounters
GROUP BY
    DATE_FORMAT(admission_datetime, '%Y-%m')
ORDER BY admission_month;


-- ============================================================
-- 4. PEAK ADMISSION HOURS
-- Identifies the hours of the day with the highest
-- patient admission activity.
-- ============================================================

SELECT
    HOUR(admission_datetime) AS admission_hour,
    COUNT(*) AS total_encounters
FROM encounters
GROUP BY
    HOUR(admission_datetime)
ORDER BY total_encounters DESC;


-- ============================================================
-- 5. DISCHARGE OUTCOMES
-- Summarizes discharge status and calculates each outcome
-- as a percentage of total encounters.
-- ============================================================

SELECT
    discharge_status,
    COUNT(*) AS total_encounters,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM encounters),
        2
    ) AS percentage_of_encounters
FROM encounters
GROUP BY discharge_status
ORDER BY total_encounters DESC;


-- ============================================================
-- 6. ENCOUNTER TYPE UTILIZATION
-- Shows how healthcare services are being utilized across
-- different encounter types.
-- ============================================================

SELECT
    encounter_type,
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(length_of_stay_hours), 2) AS avg_los_hours
FROM encounters
GROUP BY encounter_type
ORDER BY total_encounters DESC;


-- ============================================================
-- 7. MONTHLY DEPARTMENT VOLUME RANKING
-- Uses a CTE and DENSE_RANK window function to identify
-- the highest-volume departments within each month.
-- ============================================================

WITH monthly_department_volume AS (
    SELECT
        DATE_FORMAT(e.admission_datetime, '%Y-%m') AS admission_month,
        d.department_name,
        COUNT(*) AS total_encounters
    FROM encounters e
    INNER JOIN departments d
        ON e.department_id = d.department_id
    GROUP BY
        DATE_FORMAT(e.admission_datetime, '%Y-%m'),
        d.department_name
)

SELECT
    admission_month,
    department_name,
    total_encounters,
    DENSE_RANK() OVER (
        PARTITION BY admission_month
        ORDER BY total_encounters DESC
    ) AS volume_rank
FROM monthly_department_volume
ORDER BY
    admission_month,
    volume_rank,
    department_name;
