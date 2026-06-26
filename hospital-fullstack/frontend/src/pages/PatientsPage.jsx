import { useEffect, useState } from 'react'
import { Patients } from '../api/client'
import Modal from '../components/Modal'
import VitalsLine from '../components/VitalsLine'
import { IconPlus, IconEdit, IconTrash, IconSearch } from '../components/Icons'

const EMPTY_FORM = {
  first_name: '', last_name: '', date_of_birth: '', gender: 'Male',
  blood_group: '', phone: '', email: '', address: ''
}

export default function PatientsPage() {
  const [patients, setPatients] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [modalOpen, setModalOpen] = useState(false)
  const [editingId, setEditingId] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [confirmDeleteId, setConfirmDeleteId] = useState(null)
  const [error, setError] = useState('')

  const load = (q = '') => {
    setLoading(true)
    Patients.list(q)
      .then(setPatients)
      .catch(() => setError('Could not load patients — check backend connection.'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const onSearch = (e) => {
    const v = e.target.value
    setSearch(v)
    load(v)
  }

  const openCreate = () => {
    setEditingId(null)
    setForm(EMPTY_FORM)
    setModalOpen(true)
  }

  const openEdit = (p) => {
    setEditingId(p.patient_id)
    setForm({
      first_name: p.first_name, last_name: p.last_name,
      date_of_birth: p.date_of_birth?.slice(0, 10) || '',
      gender: p.gender, blood_group: p.blood_group || '',
      phone: p.phone || '', email: p.email || '', address: p.address || ''
    })
    setModalOpen(true)
  }

  const save = async () => {
    try {
      if (editingId) {
        await Patients.update(editingId, form)
      } else {
        await Patients.create(form)
      }
      setModalOpen(false)
      load(search)
    } catch (e) {
      setError(e?.response?.data?.error || 'Save failed')
    }
  }

  const doDelete = async (id) => {
    await Patients.remove(id)
    setConfirmDeleteId(null)
    load(search)
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <div className="page-eyebrow">Records</div>
          <h1>Patients</h1>
          <div className="page-subtitle">{patients.length} patients registered</div>
        </div>
        <button className="btn btn-primary" onClick={openCreate}>
          <IconPlus /> Add Patient
        </button>
      </div>
      <VitalsLine />

      {error && <div className="conn-banner conn-err" style={{ marginBottom: 14 }}>{error}</div>}

      <div className="toolbar">
        <div style={{ position: 'relative' }}>
          <IconSearch style={{ position: 'absolute', left: 11, top: 10, color: '#5C6F7C' }} width={16} height={16} />
          <input
            className="search-input"
            style={{ paddingLeft: 34 }}
            placeholder="Search by name or phone…"
            value={search}
            onChange={onSearch}
          />
        </div>
      </div>

      <div className="card">
        <div className="table-wrap">
          {loading ? (
            <div className="state-msg"><div className="spinner" /> Loading patients…</div>
          ) : patients.length === 0 ? (
            <div className="state-msg">No patients found.</div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th><th>Name</th><th>DOB</th><th>Gender</th>
                  <th>Blood Group</th><th>Phone</th><th>Email</th><th></th>
                </tr>
              </thead>
              <tbody>
                {patients.map((p) => (
                  <tr key={p.patient_id}>
                    <td>#{p.patient_id}</td>
                    <td>{p.first_name} {p.last_name}</td>
                    <td>{p.date_of_birth?.slice(0, 10)}</td>
                    <td>{p.gender}</td>
                    <td>{p.blood_group || '—'}</td>
                    <td>{p.phone || '—'}</td>
                    <td>{p.email || '—'}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-ghost btn-sm" onClick={() => openEdit(p)}><IconEdit width={14} height={14} /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDeleteId(p.patient_id)}><IconTrash width={14} height={14} /></button>
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
          title={editingId ? 'Edit Patient' : 'Add New Patient'}
          onClose={() => setModalOpen(false)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)}>Cancel</button>
            <button className="btn btn-primary" onClick={save}>{editingId ? 'Save Changes' : 'Create Patient'}</button>
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
              <label>Date of Birth</label>
              <input type="date" value={form.date_of_birth} onChange={(e) => setForm({ ...form, date_of_birth: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Gender</label>
              <select value={form.gender} onChange={(e) => setForm({ ...form, gender: e.target.value })}>
                <option>Male</option><option>Female</option><option>Other</option>
              </select>
            </div>
            <div className="form-field">
              <label>Blood Group</label>
              <input placeholder="e.g. O+" value={form.blood_group} onChange={(e) => setForm({ ...form, blood_group: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Phone</label>
              <input value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Email</label>
              <input value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Address</label>
              <input value={form.address} onChange={(e) => setForm({ ...form, address: e.target.value })} />
            </div>
          </div>
        </Modal>
      )}

      {confirmDeleteId && (
        <Modal
          title="Delete Patient?"
          onClose={() => setConfirmDeleteId(null)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setConfirmDeleteId(null)}>Cancel</button>
            <button className="btn btn-danger" onClick={() => doDelete(confirmDeleteId)}>Delete</button>
          </>}
        >
          <p style={{ color: '#5C6F7C', fontSize: 14 }}>
            This will permanently remove patient #{confirmDeleteId} and cannot be undone.
          </p>
        </Modal>
      )}
    </div>
  )
}
