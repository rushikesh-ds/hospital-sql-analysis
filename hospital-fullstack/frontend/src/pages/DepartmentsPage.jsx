import { useEffect, useState } from 'react'
import { Departments, Doctors } from '../api/client'
import Modal from '../components/Modal'
import VitalsLine from '../components/VitalsLine'
import { IconPlus, IconEdit, IconTrash } from '../components/Icons'

const EMPTY_FORM = { department_name: '', location: '', head_doctor_id: '' }

export default function DepartmentsPage() {
  const [departments, setDepartments] = useState([])
  const [doctors, setDoctors] = useState([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingId, setEditingId] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [confirmDeleteId, setConfirmDeleteId] = useState(null)
  const [error, setError] = useState('')

  const load = () => {
    setLoading(true)
    Promise.all([Departments.list(), Doctors.list()])
      .then(([dept, doc]) => { setDepartments(dept); setDoctors(doc) })
      .catch(() => setError('Could not load departments — check backend connection.'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const openCreate = () => { setEditingId(null); setForm(EMPTY_FORM); setModalOpen(true) }

  const openEdit = (d) => {
    setEditingId(d.department_id)
    setForm({
      department_name: d.department_name, location: d.location || '',
      head_doctor_id: d.head_doctor_id || ''
    })
    setModalOpen(true)
  }

  const save = async () => {
    try {
      if (editingId) await Departments.update(editingId, form)
      else await Departments.create(form)
      setModalOpen(false)
      load()
    } catch (e) {
      setError(e?.response?.data?.error || 'Save failed')
    }
  }

  const doDelete = async (id) => {
    await Departments.remove(id)
    setConfirmDeleteId(null)
    load()
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <div className="page-eyebrow">Records</div>
          <h1>Departments</h1>
          <div className="page-subtitle">{departments.length} departments</div>
        </div>
        <button className="btn btn-primary" onClick={openCreate}><IconPlus /> Add Department</button>
      </div>
      <VitalsLine />

      {error && <div className="conn-banner conn-err" style={{ marginBottom: 14 }}>{error}</div>}

      <div className="grid-3">
        {loading ? (
          <div className="state-msg"><div className="spinner" /> Loading departments…</div>
        ) : departments.length === 0 ? (
          <div className="state-msg">No departments found.</div>
        ) : departments.map((d) => (
          <div className="card card-pad" key={d.department_id}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <div className="section-title" style={{ marginBottom: 4 }}>{d.department_name}</div>
                <div style={{ fontSize: 12.5, color: '#5C6F7C' }}>{d.location || 'No location set'}</div>
              </div>
            </div>
            <div style={{ marginTop: 14, paddingTop: 12, borderTop: '1px solid #E1E8EC', fontSize: 13 }}>
              <strong>Head:</strong> {d.head_doctor_name ? `Dr. ${d.head_doctor_name}` : '—'}
            </div>
            <div style={{ display: 'flex', gap: 6, marginTop: 14 }}>
              <button className="btn btn-ghost btn-sm" onClick={() => openEdit(d)}><IconEdit width={14} height={14} /> Edit</button>
              <button className="btn btn-danger btn-sm" onClick={() => setConfirmDeleteId(d.department_id)}><IconTrash width={14} height={14} /></button>
            </div>
          </div>
        ))}
      </div>

      {modalOpen && (
        <Modal
          title={editingId ? 'Edit Department' : 'Add New Department'}
          onClose={() => setModalOpen(false)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)}>Cancel</button>
            <button className="btn btn-primary" onClick={save}>{editingId ? 'Save Changes' : 'Create Department'}</button>
          </>}
        >
          <div className="form-grid">
            <div className="form-field">
              <label>Department Name</label>
              <input value={form.department_name} onChange={(e) => setForm({ ...form, department_name: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Location</label>
              <input value={form.location} onChange={(e) => setForm({ ...form, location: e.target.value })} />
            </div>
            <div className="form-field" style={{ gridColumn: '1 / -1' }}>
              <label>Head Doctor</label>
              <select value={form.head_doctor_id} onChange={(e) => setForm({ ...form, head_doctor_id: e.target.value })}>
                <option value="">None</option>
                {doctors.map((doc) => (
                  <option key={doc.doctor_id} value={doc.doctor_id}>Dr. {doc.first_name} {doc.last_name}</option>
                ))}
              </select>
            </div>
          </div>
        </Modal>
      )}

      {confirmDeleteId && (
        <Modal
          title="Delete Department?"
          onClose={() => setConfirmDeleteId(null)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setConfirmDeleteId(null)}>Cancel</button>
            <button className="btn btn-danger" onClick={() => doDelete(confirmDeleteId)}>Delete</button>
          </>}
        >
          <p style={{ color: '#5C6F7C', fontSize: 14 }}>
            This will permanently remove this department and cannot be undone.
          </p>
        </Modal>
      )}
    </div>
  )
}
