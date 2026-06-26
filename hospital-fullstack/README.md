# 🏥 MediTrack — Hospital Data Analysis (Full-Stack)

Full-stack version of the Hospital SQL Analysis project — **Flask backend + React frontend**, connected to your existing `hospital_db` MySQL database.

This adds a real CRUD application and an analytics dashboard on top of the original SQL project, so you can demo it visually instead of just running queries in Workbench.

---

## 🧱 Tech Stack

| Layer     | Technology |
|-----------|-----------|
| Database  | MySQL 8.0+ (`hospital_db` — same one from the SQL project) |
| Backend   | Flask (Python) — REST API |
| Frontend  | React 19 + Vite + Recharts |
| Styling   | Plain CSS (custom design system, no framework) |

---

## 📁 Project Structure

```
hospital-fullstack/
├── backend/
│   ├── app.py                 ← Flask entry point
│   ├── requirements.txt
│   ├── config/
│   │   └── db.py              ← MySQL connection pool
│   └── routes/
│       ├── patients.py        ← CRUD
│       ├── doctors.py         ← CRUD
│       ├── departments.py     ← CRUD
│       ├── admissions.py      ← CRUD
│       ├── billing.py         ← CRUD
│       ├── staff.py           ← CRUD
│       ├── lab_tests.py       ← CRUD
│       └── analytics.py       ← Dashboard KPIs (read-only)
│
└── frontend/
    ├── index.html
    ├── vite.config.js
    └── src/
        ├── main.jsx
        ├── App.jsx
        ├── index.css           ← Design system
        ├── api/client.js       ← Axios API client
        ├── components/         ← Sidebar, Modal, Badge, Icons, VitalsLine
        └── pages/
            ├── Dashboard.jsx       ← Charts + KPIs
            ├── PatientsPage.jsx    ← CRUD
            ├── DoctorsPage.jsx     ← CRUD
            ├── DepartmentsPage.jsx ← CRUD
            ├── AdmissionsPage.jsx  ← CRUD
            ├── BillingPage.jsx     ← CRUD
            ├── LabTestsPage.jsx    ← CRUD
            └── StaffPage.jsx       ← CRUD
```

---

## ⚙️ Setup Instructions

### 1. Database
Make sure `hospital_db` already exists (from the SQL project). If not:
```bash
mysql -u root -p < schema/01_schema.sql
mysql -u root -p < data/02_seed_data.sql
```

### 2. Backend (Flask)
```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt
```

Edit `backend/config/db.py` and set your MySQL password:
```python
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "YOUR_MYSQL_PASSWORD",
    "database": "hospital_db",
    "port": 3306,
}
```

Run the server:
```bash
python app.py
```
Backend runs on **http://localhost:5000**

Test it: open `http://localhost:5000/api/health` in your browser — should show `{"status": "ok", "database": "connected"}`

### 3. Frontend (React)
Open a **new terminal**:
```bash
cd frontend
npm install
npm run dev
```
Frontend runs on **http://localhost:3000**

The Vite dev server automatically proxies `/api/*` calls to the Flask backend on port 5000 — no extra config needed.

---

## 🖥️ Pages

| Page | What it does |
|------|-------------|
| **Dashboard** | Live KPIs + 6 charts (admissions trend, gender split, department revenue, severity, cost breakdown, top diagnoses) |
| **Patients** | Full CRUD + search by name/phone |
| **Doctors** | Full CRUD with department dropdown |
| **Departments** | Full CRUD with head doctor assignment |
| **Admissions** | Full CRUD with status filter chips (Admitted/Discharged/ICU), severity badges |
| **Billing** | Full CRUD with payment status badges |
| **Lab Tests** | Full CRUD with result status badges |
| **Staff** | Full CRUD with department + shift assignment |

---

## 🔌 API Endpoints Reference

### CRUD (same pattern for all resources)
```
GET    /api/patients/          → list all
GET    /api/patients/<id>      → get one
POST   /api/patients/          → create
PUT    /api/patients/<id>      → update
DELETE /api/patients/<id>      → delete
```
Same pattern applies to: `doctors`, `departments`, `admissions`, `billing`, `staff`, `lab-tests`

### Analytics (read-only, powers the dashboard)
```
GET /api/analytics/dashboard-summary
GET /api/analytics/gender-distribution
GET /api/analytics/age-distribution
GET /api/analytics/admission-summary
GET /api/analytics/monthly-admissions
GET /api/analytics/severity-breakdown
GET /api/analytics/department-performance
GET /api/analytics/doctor-performance
GET /api/analytics/revenue-summary
GET /api/analytics/cost-breakdown
GET /api/analytics/payment-methods
GET /api/analytics/monthly-revenue
GET /api/analytics/top-diagnoses
GET /api/analytics/lab-test-summary
GET /api/analytics/staff-summary
GET /api/analytics/revenue-running-total      (window function)
GET /api/analytics/admission-growth           (window function — LAG)
GET /api/analytics/doctor-rank-by-department  (window function — RANK)
```

---

## 🎨 Design System

- **Theme:** "Clinical Precision" — deep navy (`#0A2342`) + teal (`#028090`) + mint (`#02C39A`)
- **Signature motif:** an ECG/vitals waveform line used as a section divider on every page
- **Typography:** Spectral (headings) + Inter (body) + JetBrains Mono (data/numbers)

---

## 🧰 Why This Matters for Your Resume

This turns the original SQL-only project into a genuine **full-stack application**:
- Backend: Flask REST API with connection pooling, parameterized queries (SQL-injection safe)
- Frontend: React with hooks, routing, charts, modals, and full CRUD
- Database: Same MySQL schema and 40+ analytical queries, now exposed as live API endpoints

**Resume bullet point:**
> Built a full-stack hospital management application with Flask REST APIs and a React dashboard, exposing 40+ MySQL analytical queries (including window functions) as live JSON endpoints with interactive charts built using Recharts.

---

## 📌 Notes

- This connects to the **same `hospital_db`** database as your SQL project — no duplicate data needed.
- If you see a red "Backend unreachable" banner on the dashboard, it means Flask isn't running on port 5000 — start it first.
- CORS is enabled in Flask so React (port 3000) can call the API (port 5000) during development.
