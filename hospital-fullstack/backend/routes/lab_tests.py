"""
Lab Tests CRUD API
"""
from flask import Blueprint, request, jsonify
from config.db import run_query, run_write

lab_tests_bp = Blueprint("lab_tests", __name__)


@lab_tests_bp.route("/", methods=["GET"])
def get_lab_tests():
    query = """
        SELECT lt.*, a.diagnosis,
               CONCAT(p.first_name, ' ', p.last_name) AS patient_name
        FROM lab_tests lt
        JOIN admissions a ON lt.admission_id = a.admission_id
        JOIN patients p   ON a.patient_id = p.patient_id
        ORDER BY lt.test_date DESC
    """
    return jsonify(run_query(query))


@lab_tests_bp.route("/<int:test_id>", methods=["GET"])
def get_lab_test(test_id):
    rows = run_query("SELECT * FROM lab_tests WHERE test_id = %s", (test_id,))
    if not rows:
        return jsonify({"error": "Lab test not found"}), 404
    return jsonify(rows[0])


@lab_tests_bp.route("/", methods=["POST"])
def create_lab_test():
    data = request.json
    new_id = run_write("""
        INSERT INTO lab_tests (admission_id, test_name, test_date, result, result_status, cost)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        data["admission_id"], data["test_name"], data.get("test_date"),
        data.get("result"), data.get("result_status", "Pending"), data.get("cost", 0)
    ))
    return jsonify({"message": "Lab test created", "test_id": new_id}), 201


@lab_tests_bp.route("/<int:test_id>", methods=["PUT"])
def update_lab_test(test_id):
    data = request.json
    run_write("""
        UPDATE lab_tests SET result = %s, result_status = %s, cost = %s
        WHERE test_id = %s
    """, (data.get("result"), data.get("result_status"), data.get("cost", 0), test_id))
    return jsonify({"message": "Lab test updated"})


@lab_tests_bp.route("/<int:test_id>", methods=["DELETE"])
def delete_lab_test(test_id):
    run_write("DELETE FROM lab_tests WHERE test_id = %s", (test_id,))
    return jsonify({"message": "Lab test deleted"})
