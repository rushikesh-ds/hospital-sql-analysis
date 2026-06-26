"""
Staff CRUD API
"""
from flask import Blueprint, request, jsonify
from config.db import run_query, run_write

staff_bp = Blueprint("staff", __name__)


@staff_bp.route("/", methods=["GET"])
def get_staff():
    query = """
        SELECT s.*, dept.department_name
        FROM staff s
        LEFT JOIN departments dept ON s.department_id = dept.department_id
        ORDER BY s.staff_id
    """
    return jsonify(run_query(query))


@staff_bp.route("/<int:staff_id>", methods=["GET"])
def get_staff_member(staff_id):
    rows = run_query("SELECT * FROM staff WHERE staff_id = %s", (staff_id,))
    if not rows:
        return jsonify({"error": "Staff not found"}), 404
    return jsonify(rows[0])


@staff_bp.route("/", methods=["POST"])
def create_staff():
    data = request.json
    new_id = run_write("""
        INSERT INTO staff (first_name, last_name, role, department_id, shift, joining_date, salary)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (
        data["first_name"], data["last_name"], data["role"],
        data.get("department_id"), data.get("shift"),
        data.get("joining_date"), data.get("salary")
    ))
    return jsonify({"message": "Staff created", "staff_id": new_id}), 201


@staff_bp.route("/<int:staff_id>", methods=["PUT"])
def update_staff(staff_id):
    data = request.json
    run_write("""
        UPDATE staff SET
            first_name = %s, last_name = %s, role = %s,
            department_id = %s, shift = %s, salary = %s
        WHERE staff_id = %s
    """, (
        data["first_name"], data["last_name"], data["role"],
        data.get("department_id"), data.get("shift"), data.get("salary"),
        staff_id
    ))
    return jsonify({"message": "Staff updated"})


@staff_bp.route("/<int:staff_id>", methods=["DELETE"])
def delete_staff(staff_id):
    run_write("DELETE FROM staff WHERE staff_id = %s", (staff_id,))
    return jsonify({"message": "Staff deleted"})
