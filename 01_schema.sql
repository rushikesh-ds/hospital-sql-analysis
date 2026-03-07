-- ============================================================
--  Hospital Data Analysis Project
--  File: 01_schema.sql
--  Description: Database schema for hospital management system
--  Dialect: MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

-- ------------------------------------------------------------
-- 1. DEPARTMENTS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS departments (
    department_id   INT             AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100)    NOT NULL,
    location        VARCHAR(100),
    head_doctor_id  INT,                          -- FK set after doctors table
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 2. DOCTORS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id       INT             AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    specialization  VARCHAR(100)    NOT NULL,
    department_id   INT,
    experience_yrs  INT,
    email           VARCHAR(100)    UNIQUE,
    phone           VARCHAR(20),
    joining_date    DATE,
    CONSTRAINT fk_doctor_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

-- Back-fill FK on departments
ALTER TABLE departments
    ADD CONSTRAINT fk_dept_head FOREIGN KEY (head_doctor_id)
        REFERENCES doctors(doctor_id);

-- ------------------------------------------------------------
-- 3. PATIENTS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS patients (
    patient_id      INT             AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    date_of_birth   DATE            NOT NULL,
    gender          ENUM('Male','Female','Other') NOT NULL,
    blood_group     VARCHAR(5),
    phone           VARCHAR(20),
    email           VARCHAR(100),
    address         TEXT,
    registered_on   DATE            DEFAULT (CURRENT_DATE)
);

-- ------------------------------------------------------------
-- 4. ADMISSIONS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS admissions (
    admission_id    INT             AUTO_INCREMENT PRIMARY KEY,
    patient_id      INT             NOT NULL,
    doctor_id       INT             NOT NULL,
    department_id   INT             NOT NULL,
    admission_date  DATE            NOT NULL,
    discharge_date  DATE,
    diagnosis       VARCHAR(255)    NOT NULL,
    severity        ENUM('Mild','Moderate','Severe','Critical') NOT NULL,
    admission_type  ENUM('Emergency','Planned','Referral')      NOT NULL,
    room_number     VARCHAR(10),
    status          ENUM('Admitted','Discharged','ICU','Transferred') DEFAULT 'Admitted',
    CONSTRAINT fk_adm_patient   FOREIGN KEY (patient_id)    REFERENCES patients(patient_id),
    CONSTRAINT fk_adm_doctor    FOREIGN KEY (doctor_id)     REFERENCES doctors(doctor_id),
    CONSTRAINT fk_adm_dept      FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- ------------------------------------------------------------
-- 5. BILLING
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS billing (
    bill_id             INT             AUTO_INCREMENT PRIMARY KEY,
    admission_id        INT             NOT NULL UNIQUE,
    patient_id          INT             NOT NULL,
    total_amount        DECIMAL(12,2)   NOT NULL,
    medication_cost     DECIMAL(12,2)   DEFAULT 0,
    surgery_cost        DECIMAL(12,2)   DEFAULT 0,
    consultation_fee    DECIMAL(12,2)   DEFAULT 0,
    room_charges        DECIMAL(12,2)   DEFAULT 0,
    insurance_covered   DECIMAL(12,2)   DEFAULT 0,
    amount_paid         DECIMAL(12,2)   DEFAULT 0,
    payment_status      ENUM('Paid','Pending','Partial','Waived') DEFAULT 'Pending',
    payment_method      ENUM('Cash','Card','Insurance','UPI','Bank Transfer'),
    bill_date           DATE,
    CONSTRAINT fk_bill_admission FOREIGN KEY (admission_id) REFERENCES admissions(admission_id),
    CONSTRAINT fk_bill_patient   FOREIGN KEY (patient_id)   REFERENCES patients(patient_id)
);

-- ------------------------------------------------------------
-- 6. MEDICATIONS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS medications (
    medication_id   INT             AUTO_INCREMENT PRIMARY KEY,
    admission_id    INT             NOT NULL,
    drug_name       VARCHAR(150)    NOT NULL,
    dosage          VARCHAR(50),
    frequency       VARCHAR(50),
    start_date      DATE,
    end_date        DATE,
    prescribed_by   INT,
    CONSTRAINT fk_med_admission FOREIGN KEY (admission_id) REFERENCES admissions(admission_id),
    CONSTRAINT fk_med_doctor    FOREIGN KEY (prescribed_by) REFERENCES doctors(doctor_id)
);

-- ------------------------------------------------------------
-- 7. LAB TESTS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lab_tests (
    test_id         INT             AUTO_INCREMENT PRIMARY KEY,
    admission_id    INT             NOT NULL,
    test_name       VARCHAR(150)    NOT NULL,
    test_date       DATE,
    result          VARCHAR(255),
    result_status   ENUM('Normal','Abnormal','Critical','Pending') DEFAULT 'Pending',
    cost            DECIMAL(8,2)    DEFAULT 0,
    CONSTRAINT fk_lab_admission FOREIGN KEY (admission_id) REFERENCES admissions(admission_id)
);

-- ------------------------------------------------------------
-- 8. STAFF
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS staff (
    staff_id        INT             AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    role            ENUM('Nurse','Technician','Admin','Pharmacist','Ward Boy') NOT NULL,
    department_id   INT,
    shift           ENUM('Morning','Evening','Night'),
    joining_date    DATE,
    salary          DECIMAL(10,2),
    CONSTRAINT fk_staff_dept FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
