"""
Hospital Data Analysis — Flask Backend
Entry point: app.py
Run: python app.py
"""
from flask import Flask, jsonify
from flask_cors import CORS

from config.db import get_connection
from routes.patients import patients_bp
from routes.doctors import doctors_bp
from routes.departments import departments_bp
from routes.admissions import admissions_bp
from routes.billing import billing_bp
from routes.staff import staff_bp
from routes.lab_tests import lab_tests_bp
from routes.analytics import analytics_bp

app = Flask(__name__)
CORS(app)  # allow React (localhost:3000) to call this API

# Register all blueprints
app.register_blueprint(patients_bp,    url_prefix="/api/patients")
app.register_blueprint(doctors_bp,     url_prefix="/api/doctors")
app.register_blueprint(departments_bp, url_prefix="/api/departments")
app.register_blueprint(admissions_bp,  url_prefix="/api/admissions")
app.register_blueprint(billing_bp,     url_prefix="/api/billing")
app.register_blueprint(staff_bp,       url_prefix="/api/staff")
app.register_blueprint(lab_tests_bp,   url_prefix="/api/lab-tests")
app.register_blueprint(analytics_bp,   url_prefix="/api/analytics")


@app.route("/api/health")
def health_check():
    """Simple endpoint to verify backend + DB connection are alive."""
    try:
        conn = get_connection()
        conn.close()
        return jsonify({"status": "ok", "database": "connected"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/")
def index():
    return jsonify({
        "message": "Hospital Data Analysis API",
        "version": "1.0",
        "endpoints": [
            "/api/patients", "/api/doctors", "/api/departments",
            "/api/admissions", "/api/billing", "/api/staff",
            "/api/lab-tests", "/api/analytics"
        ]
    })


if __name__ == "__main__":
    app.run(debug=False, port=5000)
