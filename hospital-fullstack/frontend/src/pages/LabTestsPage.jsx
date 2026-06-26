import { useEffect, useState } from 'react'
import { LabTests, Admissions } from '../api/client'
import Modal from '../components/Modal'
import VitalsLine from '../components/VitalsLine'
import { IconPlus, IconEdit, IconTrash } from '../components/Icons'

const EMPTY_FORM = {
  admission_id: '', test_name: '', test_date: '', result: '', result_status: 'Pending', cost: ''
}

const STATUS_CLASS = {
  Normal: 'badge-paid', Abnormal: 'badge-moderate', Critical: 'badge-critical', Pending: 'badge-pending'
}

export default function LabTestsPage() {
  const [tests, setTests] = useState([])
  const [admissions, setAdmissions] = useState([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingId, setEditingId] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [confirmDeleteId, setConfirmDeleteId] = useState(null)
  const [error, setError] = useState('')

  const load = () => {
    setLoading(true)
    LabTests.list()
      .then(setTests)
      .catch(() => setError('Could not load lab tests — check backend connection.'))
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    load()
    Admissions.list().then(setAdmissions).catch(() => {})
  }, [])

  const openCreate = () => { setEditingId(null); setForm(EMPTY_FORM); setModalOpen(true) }

  const openEdit = (t) => {
    setEditingId(t.test_id)
    setForm({
      admission_id: t.admission_id, test_name: t.test_name,
      test_date: t.test_date?.slice(0, 10) || '', result: t.result || '',
      result_status: t.result_status, cost: t.cost
    })
    setModalOpen(true)
  }

  const save = async () => {
    try {
      if (editingId) await LabTests.update(editingId, form)
      else await LabTests.create(form)
      setModalOpen(false)
      load()
    } catch (e) {
      setError(e?.response?.data?.error || 'Save failed')
    }
  }

  const doDelete = async (id) => {
    await LabTests.remove(id)
    setConfirmDeleteId(null)
    load()
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <div className="page-eyebrow">Diagnostics</div>
          <h1>Lab Tests</h1>
          <div className="page-subtitle">{tests.length} tests recorded</div>
        </div>
        <button className="btn btn-primary" onClick={openCreate}><IconPlus /> Add Lab Test</button>
      </div>
      <VitalsLine />

      {error && <div className="conn-banner conn-err" style={{ marginBottom: 14 }}>{error}</div>}

      <div className="card">
        <div className="table-wrap">
          {loading ? (
            <div className="state-msg"><div className="spinner" /> Loading lab tests…</div>
          ) : tests.length === 0 ? (
            <div className="state-msg">No lab tests found.</div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th><th>Patient</th><th>Test Name</th><th>Date</th>
                  <th>Result</th><th>Status</th><th>Cost</th><th></th>
                </tr>
              </thead>
              <tbody>
                {tests.map((t) => (
                  <tr key={t.test_id}>
                    <td>#{t.test_id}</td>
                    <td>{t.patient_name}</td>
                    <td>{t.test_name}</td>
                    <td>{t.test_date?.slice(0, 10) || '—'}</td>
                    <td>{t.result || '—'}</td>
                    <td><span className={`badge ${STATUS_CLASS[t.result_status] || 'badge-pending'}`}>{t.result_status}</span></td>
                    <td>₹{Number(t.cost || 0).toLocaleString('en-IN')}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-ghost btn-sm" onClick={() => openEdit(t)}><IconEdit width={14} height={14} /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDeleteId(t.test_id)}><IconTrash width={14} height={14} /></button>
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
          title={editingId ? 'Edit Lab Test' : 'Add Lab Test'}
          onClose={() => setModalOpen(false)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)}>Cancel</button>
            <button className="btn btn-primary" onClick={save}>{editingId ? 'Save Changes' : 'Create Test'}</button>
          </>}
        >
          <div className="form-grid">
            <div className="form-field" style={{ gridColumn: '1 / -1' }}>
              <label>Admission</label>
              <select value={form.admission_id} onChange={(e) => setForm({ ...form, admission_id: e.target.value })}>
                <option value="">Select admission</option>
                {admissions.map((a) => <option key={a.admission_id} value={a.admission_id}>#{a.admission_id} — {a.patient_name} ({a.diagnosis})</option>)}
              </select>
            </div>
            <div className="form-field">
              <label>Test Name</label>
              <input value={form.test_name} onChange={(e) => setForm({ ...form, test_name: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Test Date</label>
              <input type="date" value={form.test_date} onChange={(e) => setForm({ ...form, test_date: e.target.value })} />
            </div>
            <div className="form-field" style={{ gridColumn: '1 / -1' }}>
              <label>Result</label>
              <input value={form.result} onChange={(e) => setForm({ ...form, result: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Result Status</label>
              <select value={form.result_status} onChange={(e) => setForm({ ...form, result_status: e.target.value })}>
                <option>Pending</option><option>Normal</option><option>Abnormal</option><option>Critical</option>
              </select>
            </div>
            <div className="form-field">
              <label>Cost</label>
              <input type="number" value={form.cost} onChange={(e) => setForm({ ...form, cost: e.target.value })} />
            </div>
          </div>
        </Modal>
      )}

      {confirmDeleteId && (
        <Modal
          title="Delete Lab Test?"
          onClose={() => setConfirmDeleteId(null)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setConfirmDeleteId(null)}>Cancel</button>
            <button className="btn btn-danger" onClick={() => doDelete(confirmDeleteId)}>Delete</button>
          </>}
        >
          <p style={{ color: '#5C6F7C', fontSize: 14 }}>
            This will permanently remove test #{confirmDeleteId} and cannot be undone.
          </p>
        </Modal>
      )}
    </div>
  )
}
