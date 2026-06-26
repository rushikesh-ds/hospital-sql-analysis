"""
Doctors CRUD API
"""
from flask import Blueprint, request, jsonify
from config.db import run_query, run_write

doctors_bp = Blueprint("doctors", __name__)


@doctors_bp.route("/", methods=["GET"])
def get_doctors():
    query = """
        SELECT d.*, dept.department_name
        FROM doctors d
        LEFT JOIN departments dept ON d.department_id = dept.department_id
        ORDER BY d.doctor_id
    """
    return jsonify(run_query(query))


@doctors_bp.route("/<int:doctor_id>", methods=["GET"])
def get_doctor(doctor_id):
    rows = run_query("SELECT * FROM doctors WHERE doctor_id = %s", (doctor_id,))
    if not rows:
        return jsonify({"error": "Doctor not found"}), 404
    return jsonify(rows[0])


@doctors_bp.route("/", methods=["POST"])
def create_doctor():
    data = request.json
    new_id = run_write("""
        INSERT INTO doctors
            (first_name, last_name, specialization, department_id, experience_yrs, email, phone, joining_date)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        data["first_name"], data["last_name"], data["specialization"],
        data.get("department_id"), data.get("experience_yrs"),
        data.get("email"), data.get("phone"), data.get("joining_date")
    ))
    return jsonify({"message": "Doctor created", "doctor_id": new_id}), 201


@doctors_bp.route("/<int:doctor_id>", methods=["PUT"])
def update_doctor(doctor_id):
    data = request.json
    run_write("""
        UPDATE doctors SET
            first_name = %s, last_name = %s, specialization = %s,
            department_id = %s, experience_yrs = %s, email = %s, phone = %s
        WHERE doctor_id = %s
    """, (
        data["first_name"], data["last_name"], data["specialization"],
        data.get("department_id"), data.get("experience_yrs"),
        data.get("email"), data.get("phone"), doctor_id
    ))
    return jsonify({"message": "Doctor updated"})


@doctors_bp.route("/<int:doctor_id>", methods=["DELETE"])
def delete_doctor(doctor_id):
    run_write("DELETE FROM doctors WHERE doctor_id = %s", (doctor_id,))
    return jsonify({"message": "Doctor deleted"})
