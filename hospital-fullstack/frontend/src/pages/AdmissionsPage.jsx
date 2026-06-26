import { useEffect, useState } from 'react'
import { Admissions, Patients, Doctors, Departments } from '../api/client'
import Modal from '../components/Modal'
import VitalsLine from '../components/VitalsLine'
import { SeverityBadge } from '../components/Badge'
import { IconPlus, IconEdit, IconTrash } from '../components/Icons'

const EMPTY_FORM = {
  patient_id: '', doctor_id: '', department_id: '', admission_date: '',
  discharge_date: '', diagnosis: '', severity: 'Mild', admission_type: 'Planned',
  room_number: '', status: 'Admitted'
}

const STATUS_FILTERS = ['All', 'Admitted', 'Discharged', 'ICU']

export default function AdmissionsPage() {
  const [admissions, setAdmissions] = useState([])
  const [patients, setPatients] = useState([])
  const [doctors, setDoctors] = useState([])
  const [departments, setDepartments] = useState([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState('All')
  const [modalOpen, setModalOpen] = useState(false)
  const [editingId, setEditingId] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [confirmDeleteId, setConfirmDeleteId] = useState(null)
  const [error, setError] = useState('')

  const load = (status = 'All') => {
    setLoading(true)
    Admissions.list(status === 'All' ? '' : status)
      .then(setAdmissions)
      .catch(() => setError('Could not load admissions — check backend connection.'))
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    load()
    Patients.list().then(setPatients).catch(() => {})
    Doctors.list().then(setDoctors).catch(() => {})
    Departments.list().then(setDepartments).catch(() => {})
  }, [])

  const onFilter = (s) => { setStatusFilter(s); load(s) }

  const openCreate = () => { setEditingId(null); setForm(EMPTY_FORM); setModalOpen(true) }

  const openEdit = (a) => {
    setEditingId(a.admission_id)
    setForm({
      patient_id: a.patient_id, doctor_id: a.doctor_id, department_id: a.department_id,
      admission_date: a.admission_date?.slice(0, 10) || '',
      discharge_date: a.discharge_date?.slice(0, 10) || '',
      diagnosis: a.diagnosis, severity: a.severity, admission_type: a.admission_type,
      room_number: a.room_number || '', status: a.status
    })
    setModalOpen(true)
  }

  const save = async () => {
    try {
      if (editingId) await Admissions.update(editingId, form)
      else await Admissions.create(form)
      setModalOpen(false)
      load(statusFilter)
    } catch (e) {
      setError(e?.response?.data?.error || 'Save failed')
    }
  }

  const doDelete = async (id) => {
    await Admissions.remove(id)
    setConfirmDeleteId(null)
    load(statusFilter)
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <div className="page-eyebrow">Records</div>
          <h1>Admissions</h1>
          <div className="page-subtitle">{admissions.length} admission records</div>
        </div>
        <button className="btn btn-primary" onClick={openCreate}><IconPlus /> New Admission</button>
      </div>
      <VitalsLine />

      {error && <div className="conn-banner conn-err" style={{ marginBottom: 14 }}>{error}</div>}

      <div className="toolbar">
        <div style={{ display: 'flex', gap: 8 }}>
          {STATUS_FILTERS.map((s) => (
            <button key={s} className={`filter-chip ${statusFilter === s ? 'active' : ''}`} onClick={() => onFilter(s)}>
              {s}
            </button>
          ))}
        </div>
      </div>

      <div className="card">
        <div className="table-wrap">
          {loading ? (
            <div className="state-msg"><div className="spinner" /> Loading admissions…</div>
          ) : admissions.length === 0 ? (
            <div className="state-msg">No admissions found.</div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th><th>Patient</th><th>Doctor</th><th>Department</th>
                  <th>Diagnosis</th><th>Severity</th><th>Admitted</th><th>LOS</th><th>Status</th><th></th>
                </tr>
              </thead>
              <tbody>
                {admissions.map((a) => (
                  <tr key={a.admission_id}>
                    <td>#{a.admission_id}</td>
                    <td>{a.patient_name}</td>
                    <td>Dr. {a.doctor_name}</td>
                    <td>{a.department_name}</td>
                    <td>{a.diagnosis}</td>
                    <td><SeverityBadge value={a.severity} /></td>
                    <td>{a.admission_date?.slice(0, 10)}</td>
                    <td>{a.los_days} days</td>
                    <td>{a.status}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-ghost btn-sm" onClick={() => openEdit(a)}><IconEdit width={14} height={14} /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDeleteId(a.admission_id)}><IconTrash width={14} height={14} /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {modalOpen && (
        <Modal
          title={editingId ? 'Edit Admission' : 'New Admission'}
          onClose={() => setModalOpen(false)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)}>Cancel</button>
            <button className="btn btn-primary" onClick={save}>{editingId ? 'Save Changes' : 'Create Admission'}</button>
          </>}
        >
          <div className="form-grid">
            <div className="form-field">
              <label>Patient</label>
              <select value={form.patient_id} onChange={(e) => setForm({ ...form, patient_id: e.target.value })}>
                <option value="">Select patient</option>
                {patients.map((p) => <option key={p.patient_id} value={p.patient_id}>{p.first_name} {p.last_name}</option>)}
              </select>
            </div>
            <div className="form-field">
              <label>Doctor</label>
              <select value={form.doctor_id} onChange={(e) => setForm({ ...form, doctor_id: e.target.value })}>
                <option value="">Select doctor</option>
                {doctors.map((d) => <option key={d.doctor_id} value={d.doctor_id}>Dr. {d.first_name} {d.last_name}</option>)}
              </select>
            </div>
            <div className="form-field">
              <label>Department</label>
              <select value={form.department_id} onChange={(e) => setForm({ ...form, department_id: e.target.value })}>
                <option value="">Select department</option>
                {departments.map((d) => <option key={d.department_id} value={d.department_id}>{d.department_name}</option>)}
              </select>
            </div>
            <div className="form-field">
              <label>Room Number</label>
              <input value={form.room_number} onChange={(e) => setForm({ ...form, room_number: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Admission Date</label>
              <input type="date" value={form.admission_date} onChange={(e) => setForm({ ...form, admission_date: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Discharge Date</label>
              <input type="date" value={form.discharge_date} onChange={(e) => setForm({ ...form, discharge_date: e.target.value })} />
            </div>
            <div className="form-field" style={{ gridColumn: '1 / -1' }}>
              <label>Diagnosis</label>
              <input value={form.diagnosis} onChange={(e) => setForm({ ...form, diagnosis: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Severity</label>
              <select value={form.severity} onChange={(e) => setForm({ ...form, severity: e.target.value })}>
                <option>Mild</option><option>Moderate</option><option>Severe</option><option>Critical</option>
              </select>
            </div>
            <div className="form-field">
              <label>Admission Type</label>
              <select value={form.admission_type} onChange={(e) => setForm({ ...form, admission_type: e.target.value })}>
                <option>Emergency</option><option>Planned</option><option>Referral</option>
              </select>
            </div>
            <div className="form-field">
              <label>Status</label>
              <select value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value })}>
                <option>Admitted</option><option>Discharged</option><option>ICU</option><option>Transferred</option>
              </select>
            </div>
          </div>
        </Modal>
      )}

      {confirmDeleteId && (
        <Modal
          title="Delete Admission?"
          onClose={() => setConfirmDeleteId(null)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setConfirmDeleteId(null)}>Cancel</button>
            <button className="btn btn-danger" onClick={() => doDelete(confirmDeleteId)}>Delete</button>
          </>}
        >
          <p style={{ color: '#5C6F7C', fontSize: 14 }}>
            This will permanently remove admission #{confirmDeleteId} and cannot be undone.
          </p>
        </Modal>
      )}
    </div>
  )
}
