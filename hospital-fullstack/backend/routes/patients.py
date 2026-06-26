"""
Patients CRUD API
GET    /api/patients          -> list all patients
GET    /api/patients/<id>     -> get single patient
POST   /api/patients          -> create patient
PUT    /api/patients/<id>     -> update patient
DELETE /api/patients/<id>     -> delete patient
"""
from flask import Blueprint, request, jsonify
from config.db import run_query, run_write

patients_bp = Blueprint("patients", __name__)


@patients_bp.route("/", methods=["GET"])
def get_patients():
    search = request.args.get("search", "")
    if search:
        query = """
            SELECT * FROM patients
            WHERE first_name LIKE %s OR last_name LIKE %s OR phone LIKE %s
            ORDER BY patient_id DESC
        """
        like = f"%{search}%"
        rows = run_query(query, (like, like, like))
    else:
        rows = run_query("SELECT * FROM patients ORDER BY patient_id DESC")
    return jsonify(rows)


@patients_bp.route("/<int:patient_id>", methods=["GET"])
def get_patient(patient_id):
    rows = run_query("SELECT * FROM patients WHERE patient_id = %s", (patient_id,))
    if not rows:
        return jsonify({"error": "Patient not found"}), 404
    return jsonify(rows[0])


@patients_bp.route("/", methods=["POST"])
def create_patient():
    data = request.json
    required = ["first_name", "last_name", "date_of_birth", "gender"]
    for field in required:
        if not data.get(field):
            return jsonify({"error": f"'{field}' is required"}), 400

    new_id = run_write("""
        INSERT INTO patients
            (first_name, last_name, date_of_birth, gender, blood_group, phone, email, address)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        data["first_name"], data["last_name"], data["date_of_birth"], data["gender"],
        data.get("blood_group"), data.get("phone"), data.get("email"), data.get("address")
    ))
    return jsonify({"message": "Patient created", "patient_id": new_id}), 201


@patients_bp.route("/<int:patient_id>", methods=["PUT"])
def update_patient(patient_id):
    data = request.json
    run_write("""
        UPDATE patients SET
            first_name = %s, last_name = %s, date_of_birth = %s, gender = %s,
            blood_group = %s, phone = %s, email = %s, address = %s
        WHERE patient_id = %s
    """, (
        data["first_name"], data["last_name"], data["date_of_birth"], data["gender"],
        data.get("blood_group"), data.get("phone"), data.get("email"), data.get("address"),
        patient_id
    ))
    return jsonify({"message": "Patient updated"})


@patients_bp.route("/<int:patient_id>", methods=["DELETE"])
def delete_patient(patient_id):
    run_write("DELETE FROM patients WHERE patient_id = %s", (patient_id,))
    return jsonify({"message": "Patient deleted"})
