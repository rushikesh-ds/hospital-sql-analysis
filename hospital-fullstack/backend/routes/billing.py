"""
Billing CRUD API
"""
from flask import Blueprint, request, jsonify
from config.db import run_query, run_write

billing_bp = Blueprint("billing", __name__)


@billing_bp.route("/", methods=["GET"])
def get_billing():
    query = """
        SELECT b.*,
               CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
               a.diagnosis
        FROM billing b
        JOIN patients p   ON b.patient_id = p.patient_id
        JOIN admissions a ON b.admission_id = a.admission_id
        ORDER BY b.bill_date DESC
    """
    return jsonify(run_query(query))


@billing_bp.route("/<int:bill_id>", methods=["GET"])
def get_bill(bill_id):
    rows = run_query("SELECT * FROM billing WHERE bill_id = %s", (bill_id,))
    if not rows:
        return jsonify({"error": "Bill not found"}), 404
    return jsonify(rows[0])


@billing_bp.route("/", methods=["POST"])
def create_bill():
    data = request.json
    new_id = run_write("""
        INSERT INTO billing
            (admission_id, patient_id, total_amount, medication_cost, surgery_cost,
             consultation_fee, room_charges, insurance_covered, amount_paid,
             payment_status, payment_method, bill_date)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        data["admission_id"], data["patient_id"], data["total_amount"],
        data.get("medication_cost", 0), data.get("surgery_cost", 0),
        data.get("consultation_fee", 0), data.get("room_charges", 0),
        data.get("insurance_covered", 0), data.get("amount_paid", 0),
        data.get("payment_status", "Pending"), data.get("payment_method"),
        data.get("bill_date")
    ))
    return jsonify({"message": "Bill created", "bill_id": new_id}), 201


@billing_bp.route("/<int:bill_id>", methods=["PUT"])
def update_bill(bill_id):
    data = request.json
    run_write("""
        UPDATE billing SET
            total_amount = %s, amount_paid = %s, insurance_covered = %s,
            payment_status = %s, payment_method = %s
        WHERE bill_id = %s
    """, (
        data["total_amount"], data.get("amount_paid", 0), data.get("insurance_covered", 0),
        data.get("payment_status"), data.get("payment_method"), bill_id
    ))
    return jsonify({"message": "Bill updated"})


@billing_bp.route("/<int:bill_id>", methods=["DELETE"])
def delete_bill(bill_id):
    run_write("DELETE FROM billing WHERE bill_id = %s", (bill_id,))
    return jsonify({"message": "Bill deleted"})
