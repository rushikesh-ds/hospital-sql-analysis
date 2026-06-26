import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json' },
})

export default api

// ── Resource helpers ──────────────────────────────────────
export const Patients = {
  list: (search = '') => api.get(`/patients/${search ? `?search=${search}` : ''}`).then(r => r.data),
  get: (id) => api.get(`/patients/${id}`).then(r => r.data),
  create: (data) => api.post('/patients/', data).then(r => r.data),
  update: (id, data) => api.put(`/patients/${id}`, data).then(r => r.data),
  remove: (id) => api.delete(`/patients/${id}`).then(r => r.data),
}

export const Doctors = {
  list: () => api.get('/doctors/').then(r => r.data),
  create: (data) => api.post('/doctors/', data).then(r => r.data),
  update: (id, data) => api.put(`/doctors/${id}`, data).then(r => r.data),
  remove: (id) => api.delete(`/doctors/${id}`).then(r => r.data),
}

export const Departments = {
  list: () => api.get('/departments/').then(r => r.data),
  create: (data) => api.post('/departments/', data).then(r => r.data),
  update: (id, data) => api.put(`/departments/${id}`, data).then(r => r.data),
  remove: (id) => api.delete(`/departments/${id}`).then(r => r.data),
}

export const Admissions = {
  list: (status = '') => api.get(`/admissions/${status ? `?status=${status}` : ''}`).then(r => r.data),
  get: (id) => api.get(`/admissions/${id}`).then(r => r.data),
  create: (data) => api.post('/admissions/', data).then(r => r.data),
  update: (id, data) => api.put(`/admissions/${id}`, data).then(r => r.data),
  remove: (id) => api.delete(`/admissions/${id}`).then(r => r.data),
}

export const Billing = {
  list: () => api.get('/billing/').then(r => r.data),
  create: (data) => api.post('/billing/', data).then(r => r.data),
  update: (id, data) => api.put(`/billing/${id}`, data).then(r => r.data),
  remove: (id) => api.delete(`/billing/${id}`).then(r => r.data),
}

export const Staff = {
  list: () => api.get('/staff/').then(r => r.data),
  create: (data) => api.post('/staff/', data).then(r => r.data),
  update: (id, data) => api.put(`/staff/${id}`, data).then(r => r.data),
  remove: (id) => api.delete(`/staff/${id}`).then(r => r.data),
}

export const LabTests = {
  list: () => api.get('/lab-tests/').then(r => r.data),
  create: (data) => api.post('/lab-tests/', data).then(r => r.data),
  update: (id, data) => api.put(`/lab-tests/${id}`, data).then(r => r.data),
  remove: (id) => api.delete(`/lab-tests/${id}`).then(r => r.data),
}

export const Analytics = {
  dashboardSummary: () => api.get('/analytics/dashboard-summary').then(r => r.data),
  genderDistribution: () => api.get('/analytics/gender-distribution').then(r => r.data),
  ageDistribution: () => api.get('/analytics/age-distribution').then(r => r.data),
  admissionSummary: () => api.get('/analytics/admission-summary').then(r => r.data),
  monthlyAdmissions: () => api.get('/analytics/monthly-admissions').then(r => r.data),
  severityBreakdown: () => api.get('/analytics/severity-breakdown').then(r => r.data),
  departmentPerformance: () => api.get('/analytics/department-performance').then(r => r.data),
  doctorPerformance: () => api.get('/analytics/doctor-performance').then(r => r.data),
  revenueSummary: () => api.get('/analytics/revenue-summary').then(r => r.data),
  costBreakdown: () => api.get('/analytics/cost-breakdown').then(r => r.data),
  paymentMethods: () => api.get('/analytics/payment-methods').then(r => r.data),
  monthlyRevenue: () => api.get('/analytics/monthly-revenue').then(r => r.data),
  topDiagnoses: () => api.get('/analytics/top-diagnoses').then(r => r.data),
  labTestSummary: () => api.get('/analytics/lab-test-summary').then(r => r.data),
  staffSummary: () => api.get('/analytics/staff-summary').then(r => r.data),
  revenueRunningTotal: () => api.get('/analytics/revenue-running-total').then(r => r.data),
  admissionGrowth: () => api.get('/analytics/admission-growth').then(r => r.data),
  doctorRankByDepartment: () => api.get('/analytics/doctor-rank-by-department').then(r => r.data),
}

export const checkHealth = () => api.get('/health').then(r => r.data)
