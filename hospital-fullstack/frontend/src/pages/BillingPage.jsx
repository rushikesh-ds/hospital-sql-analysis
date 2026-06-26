import { useEffect, useState } from 'react'
import { Billing, Admissions, Patients } from '../api/client'
import Modal from '../components/Modal'
import VitalsLine from '../components/VitalsLine'
import { PaymentBadge } from '../components/Badge'
import { IconPlus, IconEdit, IconTrash } from '../components/Icons'

const EMPTY_FORM = {
  admission_id: '', patient_id: '', total_amount: '', medication_cost: 0, surgery_cost: 0,
  consultation_fee: 0, room_charges: 0, insurance_covered: 0, amount_paid: 0,
  payment_status: 'Pending', payment_method: 'Cash', bill_date: ''
}

function fmtMoney(n) { return `₹${Number(n || 0).toLocaleString('en-IN')}` }

export default function BillingPage() {
  const [bills, setBills] = useState([])
  const [admissions, setAdmissions] = useState([])
  const [patients, setPatients] = useState([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingId, setEditingId] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [confirmDeleteId, setConfirmDeleteId] = useState(null)
  const [error, setError] = useState('')

  const load = () => {
    setLoading(true)
    Billing.list()
      .then(setBills)
      .catch(() => setError('Could not load billing — check backend connection.'))
      .finally(() => setLoading(false))
  }

  useEffect(() => {
    load()
    Admissions.list().then(setAdmissions).catch(() => {})
    Patients.list().then(setPatients).catch(() => {})
  }, [])

  const openCreate = () => { setEditingId(null); setForm(EMPTY_FORM); setModalOpen(true) }

  const openEdit = (b) => {
    setEditingId(b.bill_id)
    setForm({
      admission_id: b.admission_id, patient_id: b.patient_id, total_amount: b.total_amount,
      medication_cost: b.medication_cost, surgery_cost: b.surgery_cost,
      consultation_fee: b.consultation_fee, room_charges: b.room_charges,
      insurance_covered: b.insurance_covered, amount_paid: b.amount_paid,
      payment_status: b.payment_status, payment_method: b.payment_method || 'Cash',
      bill_date: b.bill_date?.slice(0, 10) || ''
    })
    setModalOpen(true)
  }

  const save = async () => {
    try {
      if (editingId) await Billing.update(editingId, form)
      else await Billing.create(form)
      setModalOpen(false)
      load()
    } catch (e) {
      setError(e?.response?.data?.error || 'Save failed')
    }
  }

  const doDelete = async (id) => {
    await Billing.remove(id)
    setConfirmDeleteId(null)
    load()
  }

  const totalRevenue = bills.reduce((s, b) => s + Number(b.total_amount || 0), 0)
  const totalCollected = bills.reduce((s, b) => s + Number(b.amount_paid || 0), 0)

  return (
    <div>
      <div className="page-header">
        <div>
          <div className="page-eyebrow">Finance</div>
          <h1>Billing</h1>
          <div className="page-subtitle">{bills.length} bills · {fmtMoney(totalRevenue)} billed · {fmtMoney(totalCollected)} collected</div>
        </div>
        <button className="btn btn-primary" onClick={openCreate}><IconPlus /> New Bill</button>
      </div>
      <VitalsLine />

      {error && <div className="conn-banner conn-err" style={{ marginBottom: 14 }}>{error}</div>}

      <div className="card">
        <div className="table-wrap">
          {loading ? (
            <div className="state-msg"><div className="spinner" /> Loading bills…</div>
          ) : bills.length === 0 ? (
            <div className="state-msg">No bills found.</div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Bill ID</th><th>Patient</th><th>Diagnosis</th><th>Total</th>
                  <th>Insurance</th><th>Paid</th><th>Status</th><th>Method</th><th></th>
                </tr>
              </thead>
              <tbody>
                {bills.map((b) => (
                  <tr key={b.bill_id}>
                    <td>#{b.bill_id}</td>
                    <td>{b.patient_name}</td>
                    <td>{b.diagnosis}</td>
                    <td>{fmtMoney(b.total_amount)}</td>
                    <td>{fmtMoney(b.insurance_covered)}</td>
                    <td>{fmtMoney(b.amount_paid)}</td>
                    <td><PaymentBadge value={b.payment_status} /></td>
                    <td>{b.payment_method || '—'}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-ghost btn-sm" onClick={() => openEdit(b)}><IconEdit width={14} height={14} /></button>
                        <button className="btn btn-danger btn-sm" onClick={() => setConfirmDeleteId(b.bill_id)}><IconTrash width={14} height={14} /></button>
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
          title={editingId ? 'Edit Bill' : 'New Bill'}
          onClose={() => setModalOpen(false)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)}>Cancel</button>
            <button className="btn btn-primary" onClick={save}>{editingId ? 'Save Changes' : 'Create Bill'}</button>
          </>}
        >
          <div className="form-grid">
            <div className="form-field">
              <label>Admission</label>
              <select value={form.admission_id} onChange={(e) => {
                const adm = admissions.find(a => a.admission_id === Number(e.target.value))
                setForm({ ...form, admission_id: e.target.value, patient_id: adm?.patient_id || form.patient_id })
              }}>
                <option value="">Select admission</option>
                {admissions.map((a) => <option key={a.admission_id} value={a.admission_id}>#{a.admission_id} — {a.patient_name} ({a.diagnosis})</option>)}
              </select>
            </div>
            <div className="form-field">
              <label>Patient</label>
              <select value={form.patient_id} onChange={(e) => setForm({ ...form, patient_id: e.target.value })}>
                <option value="">Select patient</option>
                {patients.map((p) => <option key={p.patient_id} value={p.patient_id}>{p.first_name} {p.last_name}</option>)}
              </select>
            </div>
            <div className="form-field">
              <label>Total Amount</label>
              <input type="number" value={form.total_amount} onChange={(e) => setForm({ ...form, total_amount: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Bill Date</label>
              <input type="date" value={form.bill_date} onChange={(e) => setForm({ ...form, bill_date: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Medication Cost</label>
              <input type="number" value={form.medication_cost} onChange={(e) => setForm({ ...form, medication_cost: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Surgery Cost</label>
              <input type="number" value={form.surgery_cost} onChange={(e) => setForm({ ...form, surgery_cost: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Consultation Fee</label>
              <input type="number" value={form.consultation_fee} onChange={(e) => setForm({ ...form, consultation_fee: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Room Charges</label>
              <input type="number" value={form.room_charges} onChange={(e) => setForm({ ...form, room_charges: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Insurance Covered</label>
              <input type="number" value={form.insurance_covered} onChange={(e) => setForm({ ...form, insurance_covered: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Amount Paid</label>
              <input type="number" value={form.amount_paid} onChange={(e) => setForm({ ...form, amount_paid: e.target.value })} />
            </div>
            <div className="form-field">
              <label>Payment Status</label>
              <select value={form.payment_status} onChange={(e) => setForm({ ...form, payment_status: e.target.value })}>
                <option>Pending</option><option>Partial</option><option>Paid</option><option>Waived</option>
              </select>
            </div>
            <div className="form-field">
              <label>Payment Method</label>
              <select value={form.payment_method} onChange={(e) => setForm({ ...form, payment_method: e.target.value })}>
                <option>Cash</option><option>Card</option><option>Insurance</option><option>UPI</option><option>Bank Transfer</option>
              </select>
            </div>
          </div>
        </Modal>
      )}

      {confirmDeleteId && (
        <Modal
          title="Delete Bill?"
          onClose={() => setConfirmDeleteId(null)}
          footer={<>
            <button className="btn btn-ghost" onClick={() => setConfirmDeleteId(null)}>Cancel</button>
            <button className="btn btn-danger" onClick={() => doDelete(confirmDeleteId)}>Delete</button>
          </>}
        >
          <p style={{ color: '#5C6F7C', fontSize: 14 }}>
            This will permanently remove bill #{confirmDeleteId} and cannot be undone.
          </p>
        </Modal>
      )}
    </div>
  )
}
