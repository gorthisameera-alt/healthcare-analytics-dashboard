-- Duplicate patients
SELECT patient_id, COUNT(*) AS duplicate_count
FROM patients
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- Duplicate encounters
SELECT encounter_id, COUNT(*) AS duplicate_count
FROM encounters
GROUP BY encounter_id
HAVING COUNT(*) > 1;

-- Missing patient values
SELECT
    SUM(patient_id IS NULL) AS missing_patient_id,
    SUM(age IS NULL) AS missing_age,
    SUM(gender IS NULL) AS missing_gender,
    SUM(insurance_type IS NULL) AS missing_insurance
FROM patients;

-- Invalid length of stay
SELECT *
FROM encounters
WHERE length_of_stay_hours <= 0
   OR discharge_datetime < admission_datetime;

-- Encounters without valid patient
SELECT e.encounter_id, e.patient_id
FROM encounters e
LEFT JOIN patients p
    ON e.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

-- Encounters without valid department
SELECT e.encounter_id, e.department_id
FROM encounters e
LEFT JOIN departments d
    ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Invalid staffing values
SELECT *
FROM staffing
WHERE scheduled_staff < 0
   OR actual_staff < 0
   OR staffing_hours < 0;
