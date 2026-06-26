import { useEffect, useState } from 'react'
import { Staff, Departments } from '../api/client'
import Modal from '../components/Modal'
import VitalsLine from '../components/VitalsLine'
import { IconPlus, IconEdit, IconTrash } from '../components/Icons'

const EMPTY_FORM = {
  first_name: '', last_name: '', role: 'Nurse', department_id: '',
  shift: 'Morning', joining_date: '', salary: ''
}

export default function StaffPage() {
  const [staff, setStaff] = useState([])
  const [departments, setDepartments] = useState([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingId, setEditingId] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [confirmDeleteId, setConfirmDeleteId] = useState(null)
  const [error, setError] = useState('')

  const load = () => {
    setLoading(true)
    Promise.all([Staff.list(), Departments.list()])
      .then(([s, d]) => { setStaff(s); setDepartments(d) })
      .catch(() => setError('Could not load staff — check backend connection.'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const openCreate = () => { setEditingId(null); setForm(EMPTY_FORM); setModalOpen(true) }

  const openEdit = (s) => {
    setEditingId(s.staff_id)
    setForm({
      first_name: s.first_name, last_name: s.last_name, role: s.role,
      department_id: s.department_id || '', shift: s.shift || 'Morning',
      joining_date: s.joining_date?.slice(0, 10) || '', salary: s.salary || ''
    })
    setModalOpen(true)
  }

  const save = async () => {
    try {
      if (editingId) await Staff.update(editingId, form)
      else await Staff.create(form)
      setModalOpen(false)
      load()
    } catch (e) {
      setError(e?.response?.data?.error || 'Save failed')
    }
  }

  const doDelete = async (id) => {
    await Staff.remove(id)
    setConfirmDeleteId(null)
    load()
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <div className="page-eyebrow">Workforce</div>
          <h1>Staff</h1>
          <div className="page-subtitle">{staff.length} support staff</div>
        </div>
        <button className="btn btn-primary" onClick={openCreate}><IconPlus /> Add Staff</button>
      </div>
      <VitalsLine />

      {error && <div className="conn-banner conn-err" style={{ marginBottom: 14 }}>{error}</div>}

      <div className="card">
        <div className="table-wrap">
          {loading ? (
            <div className="state-msg"><div className="spinner" /> Loading staff…</div>
          ) : staff.length === 0 ? (
            <div className="state-msg">No staff found.</div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th><th>Name</th><th>Role</th><th>Department</th>
                  <th>Shift</th><th>Salary</th><th></th>
                </tr>
              </thead>
              <tbody>
                {staff.map((s) => (
                  <tr key={s.staff_id}>
                    <td>#{s.staff_id}</td>
                    <td>{s.first_name} {s.last_name}</td>
                    <td>{s.role}</td>
                    <td>{s.department_name || '—'}</td>
                    <td>{s.shift || '—'}</td>
                    <td>₹{Number(s.salary || 0).toLocaleString('en-IN')}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-ghost btn-sm" onClick={() => openEdit(s)}><IconEdit width={14} height={14} /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDeleteId(s.staff_id)}><IconTrash width={14} height={14} /></button>
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
          title={editingId ? 'Edit Staff' : 'Add Staff'}
          onClose={() => setModalOpen(false)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)}>Cancel</button>
            <button className="btn btn-primary" onClick={save}>{editingId ? 'Save Changes' : 'Create Staff'}</button>
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
              <label>Role</label>
              <select value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value })}>
                <option>Nurse</option><option>Technician</option><option>Admin</option>
                <option>Pharmacist</option><option>Ward Boy</option>
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
              <label>Shift</label>
              <select value={form.shift} onChange={(e) => setForm({ ...form, shift: e.target.value })}>
                <option>Morning</option><option>Evening</option><option>Night</option>
              </select>
            </div>
            <div className="form-field">
              <label>Joining Date</label>
              <input type="date" value={form.joining_date} onChange={(e) => setForm({ ...form, joining_date: e.target.value })} />
            </div>
            <div className="form-field" style={{ gridColumn: '1 / -1' }}>
              <label>Salary</label>
              <input type="number" value={form.salary} onChange={(e) => setForm({ ...form, salary: e.target.value })} />
            </div>
          </div>
        </Modal>
      )}

      {confirmDeleteId && (
        <Modal
          title="Delete Staff?"
          onClose={() => setConfirmDeleteId(null)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setConfirmDeleteId(null)}>Cancel</button>
            <button className="btn btn-danger" onClick={() => doDelete(confirmDeleteId)}>Delete</button>
          </>}
        >
          <p style={{ color: '#5C6F7C', fontSize: 14 }}>
            This will permanently remove this staff member and cannot be undone.
          </p>
        </Modal>
      )}
    </div>
  )
}
