"""
Admissions CRUD API
"""
from flask import Blueprint, request, jsonify
from config.db import run_query, run_write

admissions_bp = Blueprint("admissions", __name__)


@admissions_bp.route("/", methods=["GET"])
def get_admissions():
    status_filter = request.args.get("status")
    base_query = """
        SELECT a.*,
               CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
               CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
               dept.department_name,
               DATEDIFF(COALESCE(a.discharge_date, CURDATE()), a.admission_date) AS los_days
        FROM admissions a
        JOIN patients p     ON a.patient_id = p.patient_id
        JOIN doctors doc    ON a.doctor_id = doc.doctor_id
        JOIN departments dept ON a.department_id = dept.department_id
    """
    if status_filter:
        base_query += " WHERE a.status = %s"
        rows = run_query(base_query + " ORDER BY a.admission_date DESC", (status_filter,))
    else:
        rows = run_query(base_query + " ORDER BY a.admission_date DESC")
    return jsonify(rows)


@admissions_bp.route("/<int:admission_id>", methods=["GET"])
def get_admission(admission_id):
    rows = run_query("""
        SELECT a.*,
               CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
               CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
               dept.department_name
        FROM admissions a
        JOIN patients p     ON a.patient_id = p.patient_id
        JOIN doctors doc    ON a.doctor_id = doc.doctor_id
        JOIN departments dept ON a.department_id = dept.department_id
        WHERE a.admission_id = %s
    """, (admission_id,))
    if not rows:
        return jsonify({"error": "Admission not found"}), 404
    return jsonify(rows[0])


@admissions_bp.route("/", methods=["POST"])
def create_admission():
    data = request.json
    new_id = run_write("""
        INSERT INTO admissions
            (patient_id, doctor_id, department_id, admission_date, discharge_date,
             diagnosis, severity, admission_type, room_number, status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        data["patient_id"], data["doctor_id"], data["department_id"],
        data["admission_date"], data.get("discharge_date"),
        data["diagnosis"], data["severity"], data["admission_type"],
        data.get("room_number"), data.get("status", "Admitted")
    ))
    return jsonify({"message": "Admission created", "admission_id": new_id}), 201


@admissions_bp.route("/<int:admission_id>", methods=["PUT"])
def update_admission(admission_id):
    data = request.json
    run_write("""
        UPDATE admissions SET
            discharge_date = %s, diagnosis = %s, severity = %s,
            admission_type = %s, room_number = %s, status = %s
        WHERE admission_id = %s
    """, (
        data.get("discharge_date"), data["diagnosis"], data["severity"],
        data["admission_type"], data.get("room_number"), data.get("status"),
        admission_id
    ))
    return jsonify({"message": "Admission updated"})


@admissions_bp.route("/<int:admission_id>", methods=["DELETE"])
def delete_admission(admission_id):
    run_write("DELETE FROM admissions WHERE admission_id = %s", (admission_id,))
    return jsonify({"message": "Admission deleted"})
