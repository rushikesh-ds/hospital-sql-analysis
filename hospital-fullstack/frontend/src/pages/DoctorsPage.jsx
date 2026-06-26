import { useEffect, useState } from 'react'
import { Doctors, Departments } from '../api/client'
import Modal from '../components/Modal'
import VitalsLine from '../components/VitalsLine'
import { IconPlus, IconEdit, IconTrash } from '../components/Icons'

const EMPTY_FORM = {
  first_name: '', last_name: '', specialization: '', department_id: '',
  experience_yrs: '', email: '', phone: '', joining_date: ''
}

export default function DoctorsPage() {
  const [doctors, setDoctors] = useState([])
  const [departments, setDepartments] = useState([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingId, setEditingId] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [confirmDeleteId, setConfirmDeleteId] = useState(null)
  const [error, setError] = useState('')

  const load = () => {
    setLoading(true)
    Promise.all([Doctors.list(), Departments.list()])
      .then(([d, dept]) => { setDoctors(d); setDepartments(dept) })
      .catch(() => setError('Could not load doctors — check backend connection.'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const openCreate = () => { setEditingId(null); setForm(EMPTY_FORM); setModalOpen(true) }

  const openEdit = (d) => {
    setEditingId(d.doctor_id)
    setForm({
      first_name: d.first_name, last_name: d.last_name, specialization: d.specialization,
      department_id: d.department_id || '', experience_yrs: d.experience_yrs || '',
      email: d.email || '', phone: d.phone || '', joining_date: d.joining_date?.slice(0, 10) || ''
    })
    setModalOpen(true)
  }

  const save = async () => {
    try {
      if (editingId) await Doctors.update(editingId, form)
      else await Doctors.create(form)
      setModalOpen(false)
      load()
    } catch (e) {
      setError(e?.response?.data?.error || 'Save failed')
    }
  }

  const doDelete = async (id) => {
    await Doctors.remove(id)
    setConfirmDeleteId(null)
    load()
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <div className="page-eyebrow">Records</div>
          <h1>Doctors</h1>
          <div className="page-subtitle">{doctors.length} doctors on staff</div>
        </div>
        <button className="btn btn-primary" onClick={openCreate}><IconPlus /> Add Doctor</button>
      </div>
      <VitalsLine />

      {error && <div className="conn-banner conn-err" style={{ marginBottom: 14 }}>{error}</div>}

      <div className="card">
        <div className="table-wrap">
          {loading ? (
            <div className="state-msg"><div className="spinner" /> Loading doctors…</div>
          ) : doctors.length === 0 ? (
            <div className="state-msg">No doctors found.</div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th><th>Name</th><th>Specialization</th><th>Department</th>
                  <th>Experience</th><th>Phone</th><th></th>
                </tr>
              </thead>
              <tbody>
                {doctors.map((d) => (
                  <tr key={d.doctor_id}>
                    <td>#{d.doctor_id}</td>
                    <td>Dr. {d.first_name} {d.last_name}</td>
                    <td>{d.specialization}</td>
                    <td>{d.department_name || '—'}</td>
                    <td>{d.experience_yrs} yrs</td>
                    <td>{d.phone || '—'}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-ghost btn-sm" onClick={() => openEdit(d)}><IconEdit width={14} height={14} /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDeleteId(d.doctor_id)}><IconTrash width={14} height={14} /></button>
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
          title={editingId ? 'Edit Doctor' : 'Add New Doctor'}
          onClose={() => setModalOpen(false)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)}>Cancel</button>
            <button className="btn btn-primary" onClick={save}>{editingId ? 'Save Changes' : 'Create Doctor'}</button>
          </>}
        >
          <div className="form-grid">
            <div className="form-field">
              <label>First Name</label>
              <input value={form.first_name} onChange={(e) => setForm({ ...form, first_name: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Last Name</label>
              <input value={form.last_name} onChange={(e) => setForm({ ...form, last_name: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Specialization</label>
              <input value={form.specialization} onChange={(e) => setForm({ ...form, specialization: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Department</label>
              <select value={form.department_id} onChange={(e) => setForm({ ...form, department_id: e.target.value })}>
                <option value="">Select department</option>
                {departments.map((dep) => (
                  <option key={dep.department_id} value={dep.department_id}>{dep.department_name}</option>
                ))}
              </select>
            </div>
            <div className="form-field">
              <label>Experience (years)</label>
              <input type="number" value={form.experience_yrs} onChange={(e) => setForm({ ...form, experience_yrs: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Joining Date</label>
              <input type="date" value={form.joining_date} onChange={(e) => setForm({ ...form, joining_date: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Email</label>
              <input value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Phone</label>
              <input value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
            </div>
          </div>
        </Modal>
      )}

      {confirmDeleteId && (
        <Modal
          title="Delete Doctor?"
          onClose={() => setConfirmDeleteId(null)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setConfirmDeleteId(null)}>Cancel</button>
            <button className="btn btn-danger" onClick={() => doDelete(confirmDeleteId)}>Delete</button>
          </>}
        >
          <p style={{ color: '#5C6F7C', fontSize: 14 }}>
            This will permanently remove doctor #{confirmDeleteId} and cannot be undone.
          </p>
        </Modal>
      )}
    </div>
  )
}
