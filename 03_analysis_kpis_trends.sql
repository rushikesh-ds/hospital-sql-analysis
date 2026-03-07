-- ============================================================
--  Hospital Data Analysis Project
--  File: 03_analysis_kpis_trends.sql
--  Description: End-to-end KPI & trend analysis queries
--  Dialect: MySQL 8.0+
--  Sections:
--    A. Patient Demographics
--    B. Admission KPIs
--    C. Department Performance
--    D. Doctor Performance
--    E. Financial Analysis
--    F. Disease & Diagnosis Trends
--    G. Lab Test Insights
--    H. Staff Analysis
--    I. Advanced Analytics (Window Functions)
-- ============================================================

USE hospital_db;

-- ============================================================
-- A. PATIENT DEMOGRAPHICS
-- ============================================================

-- A1. Total registered patients by gender
SELECT
    gender,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_share
FROM patients
GROUP BY gender;

-- A2. Age distribution of patients (bucketed)
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18  THEN 'Under 18'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 35  THEN '18 - 34'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 50  THEN '35 - 49'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 65  THEN '50 - 64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_share
FROM patients
GROUP BY age_group
ORDER BY FIELD(age_group, 'Under 18','18 - 34','35 - 49','50 - 64','65+');

-- A3. Blood group distribution
SELECT
    blood_group,
    COUNT(*) AS count
FROM patients
GROUP BY blood_group
ORDER BY count DESC;

-- A4. New patient registrations by month (year-over-year)
SELECT
    YEAR(registered_on)  AS reg_year,
    MONTH(registered_on) AS reg_month,
    MONTHNAME(registered_on) AS month_name,
    COUNT(*) AS new_patients
FROM patients
GROUP BY reg_year, reg_month, month_name
ORDER BY reg_year, reg_month;


-- ============================================================
-- B. ADMISSION KPIs
-- ============================================================

-- B1. Overall admission summary
SELECT
    COUNT(*)                                            AS total_admissions,
    SUM(CASE WHEN status = 'Discharged'    THEN 1 ELSE 0 END) AS discharged,
    SUM(CASE WHEN status = 'Admitted'      THEN 1 ELSE 0 END) AS currently_admitted,
    SUM(CASE WHEN status = 'ICU'           THEN 1 ELSE 0 END) AS in_icu,
    ROUND(AVG(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)), 1) AS avg_length_of_stay_days
FROM admissions;

-- B2. Admissions by type and severity
SELECT
    admission_type,
    severity,
    COUNT(*) AS admission_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY admission_type), 1) AS pct_within_type
FROM admissions
GROUP BY admission_type, severity
ORDER BY admission_type, FIELD(severity,'Mild','Moderate','Severe','Critical');

-- B3. Monthly admissions trend (2023 vs 2024)
SELECT
    YEAR(admission_date)    AS yr,
    MONTH(admission_date)   AS mo,
    MONTHNAME(admission_date) AS month_name,
    COUNT(*)                AS admissions,
    ROUND(AVG(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)), 1) AS avg_los
FROM admissions
GROUP BY yr, mo, month_name
ORDER BY yr, mo;

-- B4. Peak admission days (day of week)
SELECT
    DAYNAME(admission_date) AS day_of_week,
    COUNT(*) AS admissions
FROM admissions
GROUP BY day_of_week
ORDER BY admissions DESC;

-- B5. Emergency vs non-emergency admission ratio by department
SELECT
    d.department_name,
    COUNT(*) AS total_admissions,
    SUM(CASE WHEN a.admission_type = 'Emergency' THEN 1 ELSE 0 END) AS emergency_count,
    ROUND(SUM(CASE WHEN a.admission_type = 'Emergency' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS emergency_pct
FROM admissions a
JOIN departments d ON a.department_id = d.department_id
GROUP BY d.department_name
ORDER BY emergency_pct DESC;

-- B6. Average length of stay by severity
SELECT
    severity,
    COUNT(*) AS cases,
    ROUND(AVG(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)), 1) AS avg_los_days,
    MIN(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)) AS min_los,
    MAX(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)) AS max_los
FROM admissions
GROUP BY severity
ORDER BY FIELD(severity,'Mild','Moderate','Severe','Critical');

-- B7. Readmission check: patients admitted more than once
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    COUNT(a.admission_id) AS total_admissions,
    MIN(a.admission_date) AS first_admission,
    MAX(a.admission_date) AS last_admission
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, patient_name
HAVING total_admissions > 1
ORDER BY total_admissions DESC;


-- ============================================================
-- C. DEPARTMENT PERFORMANCE
-- ============================================================

-- C1. Admissions and revenue per department
SELECT
    d.department_name,
    COUNT(a.admission_id)               AS total_admissions,
    ROUND(AVG(DATEDIFF(
        COALESCE(a.discharge_date, CURDATE()),
        a.admission_date)), 1)          AS avg_los,
    COALESCE(SUM(b.total_amount), 0)    AS total_revenue,
    COALESCE(SUM(b.amount_paid), 0)     AS revenue_collected,
    ROUND(COALESCE(SUM(b.amount_paid), 0) * 100.0 /
          NULLIF(COALESCE(SUM(b.total_amount), 0), 0), 1) AS collection_rate_pct
FROM departments d
LEFT JOIN admissions a  ON d.department_id = a.department_id
LEFT JOIN billing b     ON a.admission_id  = b.admission_id
GROUP BY d.department_name
ORDER BY total_revenue DESC;

-- C2. Critical case load per department
SELECT
    d.department_name,
    COUNT(*) AS critical_admissions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_all_critical
FROM admissions a
JOIN departments d ON a.department_id = d.department_id
WHERE a.severity = 'Critical'
GROUP BY d.department_name
ORDER BY critical_admissions DESC;

-- C3. Bed occupancy proxy: active admissions per department
SELECT
    d.department_name,
    COUNT(*) AS currently_admitted
FROM admissions a
JOIN departments d ON a.department_id = d.department_id
WHERE a.status IN ('Admitted','ICU')
GROUP BY d.department_name
ORDER BY currently_admitted DESC;


-- ============================================================
-- D. DOCTOR PERFORMANCE
-- ============================================================

-- D1. Doctor workload: admissions handled
SELECT
    doc.doctor_id,
    CONCAT(doc.first_name,' ',doc.last_name)    AS doctor_name,
    doc.specialization,
    d.department_name,
    COUNT(a.admission_id)                       AS total_admissions,
    ROUND(AVG(DATEDIFF(
        COALESCE(a.discharge_date, CURDATE()),
        a.admission_date)), 1)                  AS avg_los_days,
    SUM(CASE WHEN a.severity = 'Critical' THEN 1 ELSE 0 END) AS critical_cases
FROM doctors doc
JOIN departments d   ON doc.department_id = d.department_id
LEFT JOIN admissions a ON doc.doctor_id   = a.doctor_id
GROUP BY doc.doctor_id, doctor_name, doc.specialization, d.department_name
ORDER BY total_admissions DESC;

-- D2. Doctor revenue generation
SELECT
    CONCAT(doc.first_name,' ',doc.last_name) AS doctor_name,
    doc.specialization,
    COUNT(a.admission_id)                    AS cases,
    SUM(b.total_amount)                      AS total_billed,
    SUM(b.amount_paid)                       AS total_collected,
    ROUND(AVG(b.total_amount), 0)            AS avg_bill_per_case
FROM doctors doc
JOIN admissions a ON doc.doctor_id    = a.doctor_id
JOIN billing b   ON a.admission_id    = b.admission_id
GROUP BY doctor_name, doc.specialization
ORDER BY total_billed DESC;

-- D3. Doctor experience vs average case severity score
--     (Mild=1, Moderate=2, Severe=3, Critical=4)
SELECT
    CONCAT(doc.first_name,' ',doc.last_name) AS doctor_name,
    doc.experience_yrs,
    ROUND(AVG(
        CASE a.severity
            WHEN 'Mild'     THEN 1
            WHEN 'Moderate' THEN 2
            WHEN 'Severe'   THEN 3
            WHEN 'Critical' THEN 4
        END), 2) AS avg_severity_score
FROM doctors doc
JOIN admissions a ON doc.doctor_id = a.doctor_id
GROUP BY doctor_name, doc.experience_yrs
ORDER BY avg_severity_score DESC;


-- ============================================================
-- E. FINANCIAL ANALYSIS
-- ============================================================

-- E1. Total hospital revenue summary
SELECT
    SUM(total_amount)                       AS gross_billed,
    SUM(insurance_covered)                  AS insurance_covered,
    SUM(amount_paid)                        AS cash_collected,
    SUM(total_amount - amount_paid)         AS outstanding_balance,
    ROUND(SUM(amount_paid)*100.0/SUM(total_amount), 1) AS overall_collection_pct
FROM billing;

-- E2. Revenue breakdown by cost component
SELECT
    ROUND(SUM(medication_cost), 0)      AS total_medication_cost,
    ROUND(SUM(surgery_cost), 0)         AS total_surgery_cost,
    ROUND(SUM(consultation_fee), 0)     AS total_consultation_fee,
    ROUND(SUM(room_charges), 0)         AS total_room_charges,
    ROUND(SUM(total_amount), 0)         AS grand_total,
    ROUND(SUM(medication_cost)*100.0/SUM(total_amount), 1)   AS medication_pct,
    ROUND(SUM(surgery_cost)*100.0/SUM(total_amount), 1)      AS surgery_pct,
    ROUND(SUM(consultation_fee)*100.0/SUM(total_amount), 1)  AS consultation_pct,
    ROUND(SUM(room_charges)*100.0/SUM(total_amount), 1)      AS room_pct
FROM billing;

-- E3. Monthly revenue trend
SELECT
    YEAR(bill_date)     AS yr,
    MONTH(bill_date)    AS mo,
    MONTHNAME(bill_date) AS month_name,
    COUNT(*)            AS bills_generated,
    SUM(total_amount)   AS gross_billed,
    SUM(amount_paid)    AS collected,
    SUM(total_amount - amount_paid) AS outstanding
FROM billing
GROUP BY yr, mo, month_name
ORDER BY yr, mo;

-- E4. Payment method distribution
SELECT
    payment_method,
    COUNT(*) AS transactions,
    SUM(amount_paid) AS amount_collected,
    ROUND(SUM(amount_paid) * 100.0 / SUM(SUM(amount_paid)) OVER(), 1) AS pct_of_total
FROM billing
WHERE payment_method IS NOT NULL
GROUP BY payment_method
ORDER BY amount_collected DESC;

-- E5. Payment status breakdown
SELECT
    payment_status,
    COUNT(*) AS bill_count,
    SUM(total_amount) AS total_billed,
    SUM(amount_paid) AS collected
FROM billing
GROUP BY payment_status
ORDER BY total_billed DESC;

-- E6. High-value admissions (top 10 bills)
SELECT
    b.bill_id,
    CONCAT(p.first_name,' ',p.last_name)        AS patient_name,
    a.diagnosis,
    d.department_name,
    b.total_amount,
    b.insurance_covered,
    b.amount_paid,
    b.payment_status
FROM billing b
JOIN admissions a ON b.admission_id  = a.admission_id
JOIN patients p   ON b.patient_id    = p.patient_id
JOIN departments d ON a.department_id = d.department_id
ORDER BY b.total_amount DESC
LIMIT 10;

-- E7. Insurance dependency by department
SELECT
    d.department_name,
    ROUND(AVG(b.insurance_covered * 100.0 / NULLIF(b.total_amount, 0)), 1) AS avg_insurance_coverage_pct,
    SUM(b.insurance_covered) AS total_insurance_covered
FROM billing b
JOIN admissions a  ON b.admission_id  = a.admission_id
JOIN departments d ON a.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_insurance_coverage_pct DESC;


-- ============================================================
-- F. DISEASE & DIAGNOSIS TRENDS
-- ============================================================

-- F1. Top 15 diagnoses by frequency
SELECT
    diagnosis,
    COUNT(*) AS cases,
    ROUND(AVG(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)), 1) AS avg_los
FROM admissions
GROUP BY diagnosis
ORDER BY cases DESC
LIMIT 15;

-- F2. Diagnosis severity breakdown
SELECT
    diagnosis,
    COUNT(*) AS total_cases,
    SUM(CASE WHEN severity = 'Mild'     THEN 1 ELSE 0 END) AS mild,
    SUM(CASE WHEN severity = 'Moderate' THEN 1 ELSE 0 END) AS moderate,
    SUM(CASE WHEN severity = 'Severe'   THEN 1 ELSE 0 END) AS severe,
    SUM(CASE WHEN severity = 'Critical' THEN 1 ELSE 0 END) AS critical
FROM admissions
GROUP BY diagnosis
ORDER BY total_cases DESC
LIMIT 20;

-- F3. Most common diagnoses by age group
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, a.admission_date) < 18 THEN 'Under 18'
        WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, a.admission_date) < 35 THEN '18 - 34'
        WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, a.admission_date) < 50 THEN '35 - 49'
        WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, a.admission_date) < 65 THEN '50 - 64'
        ELSE '65+'
    END AS age_group,
    a.diagnosis,
    COUNT(*) AS cases
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY age_group, a.diagnosis
ORDER BY age_group, cases DESC;

-- F4. Cancer cases trend (Oncology department)
SELECT
    YEAR(admission_date)        AS yr,
    QUARTER(admission_date)     AS qtr,
    diagnosis,
    COUNT(*)                    AS cases,
    SUM(b.total_amount)         AS total_treatment_cost
FROM admissions a
JOIN billing b ON a.admission_id = b.admission_id
WHERE a.department_id = 5
GROUP BY yr, qtr, diagnosis
ORDER BY yr, qtr;

-- F5. Emergency diagnoses - most frequent
SELECT
    diagnosis,
    COUNT(*) AS emergency_cases,
    ROUND(AVG(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)), 1) AS avg_los
FROM admissions
WHERE admission_type = 'Emergency'
GROUP BY diagnosis
ORDER BY emergency_cases DESC
LIMIT 10;


-- ============================================================
-- G. LAB TEST INSIGHTS
-- ============================================================

-- G1. Most frequently ordered lab tests
SELECT
    test_name,
    COUNT(*) AS orders,
    SUM(CASE WHEN result_status = 'Normal'   THEN 1 ELSE 0 END) AS normal,
    SUM(CASE WHEN result_status = 'Abnormal' THEN 1 ELSE 0 END) AS abnormal,
    SUM(CASE WHEN result_status = 'Critical' THEN 1 ELSE 0 END) AS critical_results,
    ROUND(AVG(cost), 0)                                          AS avg_cost
FROM lab_tests
GROUP BY test_name
ORDER BY orders DESC;

-- G2. Critical lab result rate by department
SELECT
    d.department_name,
    COUNT(lt.test_id)   AS total_tests,
    SUM(CASE WHEN lt.result_status = 'Critical' THEN 1 ELSE 0 END) AS critical_results,
    ROUND(SUM(CASE WHEN lt.result_status = 'Critical' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(lt.test_id), 1) AS critical_rate_pct,
    SUM(lt.cost)        AS total_lab_revenue
FROM lab_tests lt
JOIN admissions a  ON lt.admission_id  = a.admission_id
JOIN departments d ON a.department_id  = d.department_id
GROUP BY d.department_name
ORDER BY critical_rate_pct DESC;

-- G3. Lab cost contribution per admission
SELECT
    a.admission_id,
    a.diagnosis,
    COUNT(lt.test_id)   AS tests_done,
    SUM(lt.cost)        AS total_lab_cost,
    b.total_amount      AS total_bill,
    ROUND(SUM(lt.cost) * 100.0 / NULLIF(b.total_amount, 0), 1) AS lab_pct_of_bill
FROM admissions a
JOIN lab_tests lt ON a.admission_id = lt.admission_id
JOIN billing b    ON a.admission_id = b.admission_id
GROUP BY a.admission_id, a.diagnosis, b.total_amount
ORDER BY lab_pct_of_bill DESC;


-- ============================================================
-- H. STAFF ANALYSIS
-- ============================================================

-- H1. Staff count by role and shift
SELECT
    role,
    SUM(CASE WHEN shift = 'Morning' THEN 1 ELSE 0 END) AS morning,
    SUM(CASE WHEN shift = 'Evening' THEN 1 ELSE 0 END) AS evening,
    SUM(CASE WHEN shift = 'Night'   THEN 1 ELSE 0 END) AS night,
    COUNT(*) AS total
FROM staff
GROUP BY role
ORDER BY total DESC;

-- H2. Average salary by role
SELECT
    role,
    COUNT(*) AS headcount,
    ROUND(AVG(salary), 0)   AS avg_salary,
    MIN(salary)             AS min_salary,
    MAX(salary)             AS max_salary,
    SUM(salary)             AS total_salary_burden
FROM staff
GROUP BY role
ORDER BY avg_salary DESC;

-- H3. Staff per department
SELECT
    d.department_name,
    COUNT(s.staff_id)   AS staff_count,
    COUNT(doc.doctor_id) AS doctor_count,
    COUNT(s.staff_id) + COUNT(DISTINCT doc.doctor_id) AS total_headcount
FROM departments d
LEFT JOIN staff s       ON d.department_id = s.department_id
LEFT JOIN doctors doc   ON d.department_id = doc.department_id
GROUP BY d.department_name
ORDER BY total_headcount DESC;

-- H4. Staff joining trend (hiring growth)
SELECT
    YEAR(joining_date) AS year_joined,
    COUNT(*)           AS staff_hired
FROM staff
GROUP BY year_joined
ORDER BY year_joined;


-- ============================================================
-- I. ADVANCED ANALYTICS (Window Functions)
-- ============================================================

-- I1. Running total of revenue by month
SELECT
    yr, mo, month_name, monthly_collected,
    SUM(monthly_collected) OVER (ORDER BY yr, mo
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                                 ) AS cumulative_revenue
FROM (
    SELECT
        YEAR(bill_date)      AS yr,
        MONTH(bill_date)     AS mo,
        MONTHNAME(bill_date) AS month_name,
        SUM(amount_paid)     AS monthly_collected
    FROM billing
    GROUP BY yr, mo, month_name
) monthly
ORDER BY yr, mo;

-- I2. Rank doctors by admissions handled within each department
SELECT
    department_name,
    doctor_name,
    total_admissions,
    RANK() OVER (PARTITION BY department_name ORDER BY total_admissions DESC) AS dept_rank
FROM (
    SELECT
        d.department_name,
        CONCAT(doc.first_name,' ',doc.last_name) AS doctor_name,
        COUNT(a.admission_id) AS total_admissions
    FROM doctors doc
    JOIN departments d   ON doc.department_id = d.department_id
    LEFT JOIN admissions a ON doc.doctor_id   = a.doctor_id
    GROUP BY d.department_name, doctor_name
) ranked_doctors
ORDER BY department_name, dept_rank;

-- I3. Month-over-month admission growth rate
SELECT
    yr, mo, month_name, admissions,
    LAG(admissions) OVER (ORDER BY yr, mo) AS prev_month_admissions,
    ROUND(
        (admissions - LAG(admissions) OVER (ORDER BY yr, mo))
        * 100.0 / NULLIF(LAG(admissions) OVER (ORDER BY yr, mo), 0),
    1) AS mom_growth_pct
FROM (
    SELECT
        YEAR(admission_date)       AS yr,
        MONTH(admission_date)      AS mo,
        MONTHNAME(admission_date)  AS month_name,
        COUNT(*)                   AS admissions
    FROM admissions
    GROUP BY yr, mo, month_name
) monthly_adm
ORDER BY yr, mo;

-- I4. Patient billing percentile (who falls in top 25% by spend)
SELECT
    patient_name,
    total_spend,
    NTILE(4) OVER (ORDER BY total_spend DESC) AS spend_quartile,
    PERCENT_RANK() OVER (ORDER BY total_spend) AS spend_percentile
FROM (
    SELECT
        CONCAT(p.first_name,' ',p.last_name) AS patient_name,
        SUM(b.total_amount) AS total_spend
    FROM billing b
    JOIN patients p ON b.patient_id = p.patient_id
    GROUP BY patient_name
) patient_spend
ORDER BY total_spend DESC;

-- I5. 3-month rolling average of admissions
SELECT
    yr, mo, month_name, admissions,
    ROUND(AVG(admissions) OVER (
        ORDER BY yr, mo
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 1) AS rolling_3mo_avg
FROM (
    SELECT
        YEAR(admission_date)      AS yr,
        MONTH(admission_date)     AS mo,
        MONTHNAME(admission_date) AS month_name,
        COUNT(*)                  AS admissions
    FROM admissions
    GROUP BY yr, mo, month_name
) monthly_adm
ORDER BY yr, mo;

-- I6. Department revenue contribution ranked
SELECT
    department_name,
    dept_revenue,
    ROUND(dept_revenue * 100.0 / SUM(dept_revenue) OVER(), 1) AS revenue_pct,
    RANK() OVER (ORDER BY dept_revenue DESC) AS revenue_rank
FROM (
    SELECT
        d.department_name,
        SUM(b.total_amount) AS dept_revenue
    FROM billing b
    JOIN admissions a  ON b.admission_id  = a.admission_id
    JOIN departments d ON a.department_id = d.department_id
    GROUP BY d.department_name
) dept_rev;

-- I7. Patient LTV (lifetime value) - total spend per patient with rank
SELECT
    CONCAT(p.first_name,' ',p.last_name) AS patient_name,
    p.gender,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
    COUNT(DISTINCT b.bill_id)   AS total_visits,
    SUM(b.total_amount)         AS lifetime_billed,
    SUM(b.amount_paid)          AS lifetime_paid,
    DENSE_RANK() OVER (ORDER BY SUM(b.total_amount) DESC) AS ltv_rank
FROM patients p
JOIN billing b ON p.patient_id = b.patient_id
GROUP BY p.patient_id, patient_name, p.gender, age
ORDER BY lifetime_billed DESC;


-- ============================================================
-- BONUS: SUMMARY DASHBOARD VIEW
-- ============================================================
CREATE OR REPLACE VIEW vw_hospital_dashboard AS
SELECT
    (SELECT COUNT(*) FROM patients)                        AS total_patients,
    (SELECT COUNT(*) FROM admissions)                      AS total_admissions,
    (SELECT COUNT(*) FROM admissions WHERE status='Admitted') AS active_admissions,
    (SELECT COUNT(*) FROM doctors)                         AS total_doctors,
    (SELECT COUNT(*) FROM staff)                           AS total_support_staff,
    (SELECT ROUND(SUM(total_amount),0) FROM billing)       AS gross_revenue,
    (SELECT ROUND(SUM(amount_paid),0) FROM billing)        AS revenue_collected,
    (SELECT ROUND(AVG(DATEDIFF(
        COALESCE(discharge_date, CURDATE()), admission_date
    )),1) FROM admissions)                                  AS avg_length_of_stay,
    (SELECT ROUND(SUM(CASE WHEN severity='Critical' THEN 1 ELSE 0 END)
                  * 100.0 / COUNT(*), 1)
     FROM admissions)                                       AS critical_case_pct;

-- Retrieve the dashboard
SELECT * FROM vw_hospital_dashboard;
