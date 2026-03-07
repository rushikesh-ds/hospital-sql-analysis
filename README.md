# 🏥 Hospital Data Analysis — End-to-End SQL Project

> A production-grade SQL project analyzing healthcare operations across patients, doctors, departments, billing, labs, and staff using **MySQL 8.0+**.

---

## 📁 Project Structure

```
hospital-sql-analysis/
│
├── schema/
│   └── 01_schema.sql          # Full DDL — 8 tables with constraints & FKs
│
├── data/
│   └── 02_seed_data.sql       # 200+ rows across all tables (2023–2024)
│
├── analysis/
│   └── 03_analysis_kpis_trends.sql   # 40+ KPI & trend queries
│
└── README.md
```

---

## 🗃️ Database Schema

| Table         | Description                              | Key Columns |
|---------------|------------------------------------------|-------------|
| `departments` | Hospital departments                     | department_id, name, head_doctor |
| `doctors`     | Doctor profiles & specializations        | doctor_id, specialization, experience |
| `patients`    | Patient demographics                     | patient_id, DOB, gender, blood_group |
| `admissions`  | Hospital admission records               | admission_id, severity, diagnosis, LOS |
| `billing`     | Financial transactions per admission     | total_amount, insurance, payment_status |
| `medications` | Drugs prescribed during admission        | drug_name, dosage, frequency |
| `lab_tests`   | Diagnostic tests ordered                 | test_name, result_status, cost |
| `staff`       | Non-doctor hospital staff                | role, shift, salary |

### ER Relationships
```
departments ──< doctors
departments ──< admissions ──< billing
departments ──< admissions ──< medications
departments ──< admissions ──< lab_tests
departments ──< staff
patients    ──< admissions
doctors     ──< admissions
```

---

## 📊 Analysis Sections

### A · Patient Demographics
| Query | Insight |
|-------|---------|
| A1 | Gender distribution with % share |
| A2 | Age group buckets (Under 18 → 65+) |
| A3 | Blood group prevalence |
| A4 | Monthly new patient registrations |

### B · Admission KPIs
| Query | Insight |
|-------|---------|
| B1 | Total admissions, discharged, ICU, avg LOS |
| B2 | Admission type × severity cross-tab |
| B3 | Monthly admission trend with avg LOS |
| B4 | Peak admission days of week |
| B5 | Emergency ratio per department |
| B6 | Length of stay by severity level |
| B7 | Readmission patients (admitted 2+ times) |

### C · Department Performance
| Query | Insight |
|-------|---------|
| C1 | Revenue & collection rate per department |
| C2 | Critical case load by department |
| C3 | Active (current) bed occupancy |

### D · Doctor Performance
| Query | Insight |
|-------|---------|
| D1 | Workload: admissions + critical cases per doctor |
| D2 | Revenue generated per doctor |
| D3 | Experience vs average severity score |

### E · Financial Analysis
| Query | Insight |
|-------|---------|
| E1 | Gross billed vs collected vs outstanding |
| E2 | Cost component breakdown (surgery / meds / consult / rooms) |
| E3 | Monthly revenue trend |
| E4 | Payment method distribution |
| E5 | Payment status breakdown |
| E6 | Top 10 highest-value admissions |
| E7 | Insurance dependency by department |

### F · Disease & Diagnosis Trends
| Query | Insight |
|-------|---------|
| F1 | Top 15 diagnoses by frequency |
| F2 | Severity breakdown per diagnosis |
| F3 | Most common diagnoses by patient age group |
| F4 | Oncology cancer trends by quarter |
| F5 | Emergency-specific diagnosis frequency |

### G · Lab Test Insights
| Query | Insight |
|-------|---------|
| G1 | Most ordered tests + result status breakdown |
| G2 | Critical lab result rate by department |
| G3 | Lab cost as % of total admission bill |

### H · Staff Analysis
| Query | Insight |
|-------|---------|
| H1 | Staff count by role and shift |
| H2 | Salary analysis by role |
| H3 | Staff + doctor headcount per department |
| H4 | Yearly hiring growth trend |

### I · Advanced Analytics *(Window Functions)*
| Query | Insight |
|-------|---------|
| I1 | Cumulative revenue by month (running total) |
| I2 | Doctor rank by admissions within department |
| I3 | Month-over-month admission growth % |
| I4 | Patient billing percentile & quartile (NTILE) |
| I5 | 3-month rolling average of admissions |
| I6 | Department revenue % contribution with rank |
| I7 | Patient lifetime value (LTV) with DENSE_RANK |

### Bonus · Dashboard View
```sql
SELECT * FROM vw_hospital_dashboard;
-- Returns 9 key hospital metrics in one row
```

---

## 🔑 Key Business Insights (Sample Findings)

- **Oncology** generates the highest revenue but also the longest average length of stay
- **Emergency** department handles the highest share of critical cases
- **Insurance** covers ~60–70% of bills in surgical departments
- Doctors with **15+ years experience** are disproportionately assigned critical cases
- **Month-over-month** admissions peaked in Q2 2023 with a decline entering 2024
- Only **~40% of total billed amount** is paid out-of-pocket; the rest is insurance or outstanding

---

## ⚙️ How to Run

### Prerequisites
- MySQL 8.0 or higher
- MySQL Workbench / DBeaver / CLI

### Steps

```sql
-- Step 1: Run schema
SOURCE schema/01_schema.sql;

-- Step 2: Load seed data
SOURCE data/02_seed_data.sql;

-- Step 3: Run any analysis query
SOURCE analysis/03_analysis_kpis_trends.sql;
```

Or via CLI:
```bash
mysql -u root -p < schema/01_schema.sql
mysql -u root -p < data/02_seed_data.sql
mysql -u root -p hospital_db < analysis/03_analysis_kpis_trends.sql
```

---

## 🧰 SQL Concepts Demonstrated

| Concept | Used In |
|---------|---------|
| DDL (CREATE, ALTER, FK) | Schema design |
| DML (INSERT, UPDATE) | Seed data |
| Aggregations (SUM, AVG, COUNT) | All KPIs |
| GROUP BY + HAVING | Readmission, top diagnoses |
| CASE WHEN / IIF | Severity scoring, breakdowns |
| JOINs (INNER, LEFT) | Cross-table analysis |
| Subqueries | Dashboard view, percentile |
| CTEs (inline subqueries) | Trend queries |
| Window Functions | Section I — all 7 queries |
| RANK / DENSE_RANK / NTILE | Doctor rank, LTV ranking |
| LAG / LEAD | MoM growth rate |
| Rolling Averages | 3-month rolling window |
| Views | Dashboard summary |
| COALESCE / NULLIF | Handling NULLs safely |

---

## 📌 Dataset Overview

| Entity | Count |
|--------|-------|
| Departments | 10 |
| Doctors | 15 |
| Patients | 50 |
| Admissions | 60 |
| Billing Records | 58 |
| Medications | 20 |
| Lab Tests | 28 |
| Staff Members | 20 |

---

## 👤 Author

Built as an end-to-end SQL portfolio project showcasing database design, realistic healthcare data modelling, and advanced MySQL analytics.

---

## 📄 License

MIT — free to use, extend, and learn from.
