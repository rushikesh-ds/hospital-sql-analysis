"""
Analytics API — powers the React dashboard with KPIs, charts, and trends.
All endpoints are read-only (GET) and map directly to queries from
analysis/03_analysis_kpis_trends.sql
"""
from flask import Blueprint, jsonify
from config.db import run_query

analytics_bp = Blueprint("analytics", __name__)


# ── DASHBOARD SUMMARY (uses the VIEW) ──────────────────────────
@analytics_bp.route("/dashboard-summary", methods=["GET"])
def dashboard_summary():
    rows = run_query("SELECT * FROM vw_hospital_dashboard")
    return jsonify(rows[0] if rows else {})


# ── A. PATIENT DEMOGRAPHICS ────────────────────────────────────
@analytics_bp.route("/gender-distribution", methods=["GET"])
def gender_distribution():
    query = """
        SELECT gender, COUNT(*) AS total_patients,
               ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_share
        FROM patients GROUP BY gender
    """
    return jsonify(run_query(query))


@analytics_bp.route("/age-distribution", methods=["GET"])
def age_distribution():
    query = """
        SELECT
            CASE
                WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18 THEN 'Under 18'
                WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 35 THEN '18-34'
                WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 50 THEN '35-49'
                WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 65 THEN '50-64'
                ELSE '65+'
            END AS age_group,
            COUNT(*) AS patient_count
        FROM patients
        GROUP BY age_group
        ORDER BY FIELD(age_group,'Under 18','18-34','35-49','50-64','65+')
    """
    return jsonify(run_query(query))


# ── B. ADMISSION KPIs ───────────────────────────────────────────
@analytics_bp.route("/admission-summary", methods=["GET"])
def admission_summary():
    query = """
        SELECT
            COUNT(*) AS total_admissions,
            SUM(CASE WHEN status='Discharged' THEN 1 ELSE 0 END) AS discharged,
            SUM(CASE WHEN status='Admitted'   THEN 1 ELSE 0 END) AS currently_admitted,
            ROUND(AVG(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)), 1) AS avg_length_of_stay
        FROM admissions
    """
    rows = run_query(query)
    return jsonify(rows[0] if rows else {})


@analytics_bp.route("/monthly-admissions", methods=["GET"])
def monthly_admissions():
    query = """
        SELECT YEAR(admission_date) AS yr, MONTH(admission_date) AS mo,
               MONTHNAME(admission_date) AS month_name, COUNT(*) AS admissions
        FROM admissions
        GROUP BY yr, mo, month_name
        ORDER BY yr, mo
    """
    return jsonify(run_query(query))


@analytics_bp.route("/severity-breakdown", methods=["GET"])
def severity_breakdown():
    query = """
        SELECT severity, COUNT(*) AS cases,
               ROUND(AVG(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)), 1) AS avg_los
        FROM admissions
        GROUP BY severity
        ORDER BY FIELD(severity,'Mild','Moderate','Severe','Critical')
    """
    return jsonify(run_query(query))


# ── C. DEPARTMENT PERFORMANCE ───────────────────────────────────
@analytics_bp.route("/department-performance", methods=["GET"])
def department_performance():
    query = """
        SELECT d.department_name,
               COUNT(a.admission_id) AS total_admissions,
               COALESCE(SUM(b.total_amount), 0) AS total_revenue,
               COALESCE(SUM(b.amount_paid), 0) AS revenue_collected,
               ROUND(COALESCE(SUM(b.amount_paid),0)*100.0/NULLIF(COALESCE(SUM(b.total_amount),0),0),1) AS collection_rate_pct
        FROM departments d
        LEFT JOIN admissions a ON d.department_id = a.department_id
        LEFT JOIN billing b    ON a.admission_id  = b.admission_id
        GROUP BY d.department_name
        ORDER BY total_revenue DESC
    """
    return jsonify(run_query(query))


# ── D. DOCTOR PERFORMANCE ───────────────────────────────────────
@analytics_bp.route("/doctor-performance", methods=["GET"])
def doctor_performance():
    query = """
        SELECT doc.doctor_id, CONCAT(doc.first_name,' ',doc.last_name) AS doctor_name,
               doc.specialization, d.department_name,
               COUNT(a.admission_id) AS total_admissions,
               SUM(CASE WHEN a.severity='Critical' THEN 1 ELSE 0 END) AS critical_cases
        FROM doctors doc
        JOIN departments d ON doc.department_id = d.department_id
        LEFT JOIN admissions a ON doc.doctor_id = a.doctor_id
        GROUP BY doc.doctor_id, doctor_name, doc.specialization, d.department_name
        ORDER BY total_admissions DESC
    """
    return jsonify(run_query(query))


# ── E. FINANCIAL ANALYSIS ───────────────────────────────────────
@analytics_bp.route("/revenue-summary", methods=["GET"])
def revenue_summary():
    query = """
        SELECT
            SUM(total_amount) AS gross_billed,
            SUM(insurance_covered) AS insurance_covered,
            SUM(amount_paid) AS cash_collected,
            SUM(total_amount - amount_paid) AS outstanding_balance,
            ROUND(SUM(amount_paid)*100.0/SUM(total_amount),1) AS collection_pct
        FROM billing
    """
    rows = run_query(query)
    return jsonify(rows[0] if rows else {})


@analytics_bp.route("/cost-breakdown", methods=["GET"])
def cost_breakdown():
    query = """
        SELECT
            ROUND(SUM(medication_cost),0)  AS medication_cost,
            ROUND(SUM(surgery_cost),0)     AS surgery_cost,
            ROUND(SUM(consultation_fee),0) AS consultation_fee,
            ROUND(SUM(room_charges),0)     AS room_charges
        FROM billing
    """
    rows = run_query(query)
    return jsonify(rows[0] if rows else {})


@analytics_bp.route("/payment-methods", methods=["GET"])
def payment_methods():
    query = """
        SELECT payment_method, COUNT(*) AS transactions, SUM(amount_paid) AS amount_collected
        FROM billing
        WHERE payment_method IS NOT NULL
        GROUP BY payment_method
        ORDER BY amount_collected DESC
    """
    return jsonify(run_query(query))


@analytics_bp.route("/monthly-revenue", methods=["GET"])
def monthly_revenue():
    query = """
        SELECT YEAR(bill_date) AS yr, MONTH(bill_date) AS mo, MONTHNAME(bill_date) AS month_name,
               SUM(total_amount) AS gross_billed, SUM(amount_paid) AS collected
        FROM billing
        GROUP BY yr, mo, month_name
        ORDER BY yr, mo
    """
    return jsonify(run_query(query))


# ── F. DISEASE TRENDS ────────────────────────────────────────────
@analytics_bp.route("/top-diagnoses", methods=["GET"])
def top_diagnoses():
    query = """
        SELECT diagnosis, COUNT(*) AS cases,
               ROUND(AVG(DATEDIFF(COALESCE(discharge_date, CURDATE()), admission_date)),1) AS avg_los
        FROM admissions
        GROUP BY diagnosis
        ORDER BY cases DESC
        LIMIT 10
    """
    return jsonify(run_query(query))


# ── G. LAB TESTS ─────────────────────────────────────────────────
@analytics_bp.route("/lab-test-summary", methods=["GET"])
def lab_test_summary():
    query = """
        SELECT test_name, COUNT(*) AS orders,
               SUM(CASE WHEN result_status='Critical' THEN 1 ELSE 0 END) AS critical_results,
               ROUND(AVG(cost),0) AS avg_cost
        FROM lab_tests
        GROUP BY test_name
        ORDER BY orders DESC
    """
    return jsonify(run_query(query))


# ── H. STAFF ANALYSIS ─────────────────────────────────────────
@analytics_bp.route("/staff-summary", methods=["GET"])
def staff_summary():
    query = """
        SELECT role, COUNT(*) AS headcount, ROUND(AVG(salary),0) AS avg_salary
        FROM staff
        GROUP BY role
        ORDER BY avg_salary DESC
    """
    return jsonify(run_query(query))


# ── I. WINDOW FUNCTIONS / ADVANCED ──────────────────────────────
@analytics_bp.route("/revenue-running-total", methods=["GET"])
def revenue_running_total():
    query = """
        SELECT yr, mo, month_name, monthly_collected,
               SUM(monthly_collected) OVER (ORDER BY yr, mo ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
        FROM (
            SELECT YEAR(bill_date) AS yr, MONTH(bill_date) AS mo, MONTHNAME(bill_date) AS month_name,
                   SUM(amount_paid) AS monthly_collected
            FROM billing
            GROUP BY yr, mo, month_name
        ) monthly
        ORDER BY yr, mo
    """
    return jsonify(run_query(query))


@analytics_bp.route("/admission-growth", methods=["GET"])
def admission_growth():
    query = """
        SELECT yr, mo, month_name, admissions,
               LAG(admissions) OVER (ORDER BY yr, mo) AS prev_month,
               ROUND((admissions - LAG(admissions) OVER (ORDER BY yr, mo)) * 100.0 /
                     NULLIF(LAG(admissions) OVER (ORDER BY yr, mo), 0), 1) AS mom_growth_pct
        FROM (
            SELECT YEAR(admission_date) AS yr, MONTH(admission_date) AS mo,
                   MONTHNAME(admission_date) AS month_name, COUNT(*) AS admissions
            FROM admissions
            GROUP BY yr, mo, month_name
        ) m
        ORDER BY yr, mo
    """
    return jsonify(run_query(query))


@analytics_bp.route("/doctor-rank-by-department", methods=["GET"])
def doctor_rank():
    query = """
        SELECT department_name, doctor_name, total_admissions,
               RANK() OVER (PARTITION BY department_name ORDER BY total_admissions DESC) AS dept_rank
        FROM (
            SELECT d.department_name, CONCAT(doc.first_name,' ',doc.last_name) AS doctor_name,
                   COUNT(a.admission_id) AS total_admissions
            FROM doctors doc
            JOIN departments d ON doc.department_id = d.department_id
            LEFT JOIN admissions a ON doc.doctor_id = a.doctor_id
            GROUP BY d.department_name, doctor_name
        ) ranked
        ORDER BY department_name, dept_rank
    """
    return jsonify(run_query(query))
