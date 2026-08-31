-- Healthcare Operations Analytics
-- Database and table setup

CREATE DATABASE healthcare_analytics;

USE healthcare_analytics;

CREATE TABLE departments (
    department_id VARCHAR(10) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    service_type VARCHAR(50) NOT NULL
);

CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    age INT,
    gender VARCHAR(20),
    insurance_type VARCHAR(50)
);

CREATE TABLE encounters (
    encounter_id VARCHAR(15) PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    department_id VARCHAR(10) NOT NULL,
    admission_datetime DATETIME,
    discharge_datetime DATETIME,
    length_of_stay_hours DECIMAL(10,1),
    encounter_type VARCHAR(30),
    discharge_status VARCHAR(30),

    CONSTRAINT fk_encounter_patient
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id),

    CONSTRAINT fk_encounter_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE staffing (
    staffing_date DATE,
    department_id VARCHAR(10) NOT NULL,
    shift VARCHAR(20),
    scheduled_staff INT,
    actual_staff INT,
    staffing_hours INT,

    CONSTRAINT fk_staffing_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
