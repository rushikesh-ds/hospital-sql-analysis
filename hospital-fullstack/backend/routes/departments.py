"""
Departments CRUD API
"""
from flask import Blueprint, request, jsonify
from config.db import run_query, run_write

departments_bp = Blueprint("departments", __name__)


@departments_bp.route("/", methods=["GET"])
def get_departments():
    query = """
        SELECT dept.*, CONCAT(doc.first_name, ' ', doc.last_name) AS head_doctor_name
        FROM departments dept
        LEFT JOIN doctors doc ON dept.head_doctor_id = doc.doctor_id
        ORDER BY dept.department_id
    """
    return jsonify(run_query(query))


@departments_bp.route("/<int:dept_id>", methods=["GET"])
def get_department(dept_id):
    rows = run_query("SELECT * FROM departments WHERE department_id = %s", (dept_id,))
    if not rows:
        return jsonify({"error": "Department not found"}), 404
    return jsonify(rows[0])


@departments_bp.route("/", methods=["POST"])
def create_department():
    data = request.json
    new_id = run_write("""
        INSERT INTO departments (department_name, location, head_doctor_id)
        VALUES (%s, %s, %s)
    """, (data["department_name"], data.get("location"), data.get("head_doctor_id")))
    return jsonify({"message": "Department created", "department_id": new_id}), 201


@departments_bp.route("/<int:dept_id>", methods=["PUT"])
def update_department(dept_id):
    data = request.json
    run_write("""
        UPDATE departments SET department_name = %s, location = %s, head_doctor_id = %s
        WHERE department_id = %s
    """, (data["department_name"], data.get("location"), data.get("head_doctor_id"), dept_id))
    return jsonify({"message": "Department updated"})


@departments_bp.route("/<int:dept_id>", methods=["DELETE"])
def delete_department(dept_id):
    run_write("DELETE FROM departments WHERE department_id = %s", (dept_id,))
    return jsonify({"message": "Department deleted"})
