import { useEffect, useState } from 'react'
import {
  ResponsiveContainer, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  LineChart, Line, PieChart, Pie, Cell, Legend,
} from 'recharts'
import { Analytics, checkHealth } from '../api/client'
import VitalsLine from '../components/VitalsLine'

const COLORS = ['#028090', '#1C7293', '#065A82', '#02C39A', '#5C6F7C', '#0A2342']

function fmtMoney(n) {
  if (n == null) return '₹0'
  const v = Number(n)
  if (v >= 100000) return `₹${(v / 100000).toFixed(1)}L`
  if (v >= 1000) return `₹${(v / 1000).toFixed(1)}K`
  return `₹${v.toFixed(0)}`
}

export default function Dashboard() {
  const [summary, setSummary] = useState(null)
  const [gender, setGender] = useState([])
  const [monthlyAdm, setMonthlyAdm] = useState([])
  const [severity, setSeverity] = useState([])
  const [deptPerf, setDeptPerf] = useState([])
  const [costBreakdown, setCostBreakdown] = useState(null)
  const [topDiagnoses, setTopDiagnoses] = useState([])
  const [dbStatus, setDbStatus] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.allSettled([
      checkHealth(),
      Analytics.dashboardSummary(),
      Analytics.genderDistribution(),
      Analytics.monthlyAdmissions(),
      Analytics.severityBreakdown(),
      Analytics.departmentPerformance(),
      Analytics.costBreakdown(),
      Analytics.topDiagnoses(),
    ]).then(([health, sum, gen, ma, sev, dept, cost, diag]) => {
      setDbStatus(health.status === 'fulfilled' ? health.value : { status: 'error' })
      if (sum.status === 'fulfilled') setSummary(sum.value)
      if (gen.status === 'fulfilled') setGender(gen.value)
      if (ma.status === 'fulfilled') setMonthlyAdm(ma.value)
      if (sev.status === 'fulfilled') setSeverity(sev.value)
      if (dept.status === 'fulfilled') setDeptPerf(dept.value.slice(0, 6))
      if (cost.status === 'fulfilled') setCostBreakdown(cost.value)
      if (diag.status === 'fulfilled') setTopDiagnoses(diag.value.slice(0, 6))
      setLoading(false)
    })
  }, [])

  const costData = costBreakdown ? [
    { name: 'Surgery', value: Number(costBreakdown.surgery_cost || 0) },
    { name: 'Medication', value: Number(costBreakdown.medication_cost || 0) },
    { name: 'Room', value: Number(costBreakdown.room_charges || 0) },
    { name: 'Consultation', value: Number(costBreakdown.consultation_fee || 0) },
  ] : []

  return (
    <div>
      <div className="page-header">
        <div>
          <div className="page-eyebrow">Overview</div>
          <h1>Hospital Dashboard</h1>
          <div className="page-subtitle">Live KPIs pulled directly from MySQL via Flask API</div>
        </div>
      </div>

      {dbStatus && (
        <div className={`conn-banner ${dbStatus.status === 'ok' ? 'conn-ok' : 'conn-err'}`}>
          <span className="dot" />
          {dbStatus.status === 'ok'
            ? 'Connected to hospital_db'
            : 'Backend unreachable — start Flask server on port 5000'}
        </div>
      )}

      <VitalsLine />

      {loading ? (
        <div className="state-msg"><div className="spinner" /> Loading dashboard…</div>
      ) : (
        <>
          {/* KPI Row */}
          <div className="kpi-grid">
            <div className="kpi-card">
              <div className="kpi-label">Total Patients</div>
              <div className="kpi-value">{summary?.total_patients ?? '—'}</div>
              <div className="kpi-sub">Registered in system</div>
            </div>
            <div className="kpi-card">
              <div className="kpi-label">Total Admissions</div>
              <div className="kpi-value">{summary?.total_admissions ?? '—'}</div>
              <div className="kpi-sub">{summary?.active_admissions ?? 0} currently admitted</div>
            </div>
            <div className="kpi-card">
              <div className="kpi-label">Gross Revenue</div>
              <div className="kpi-value mint">{fmtMoney(summary?.gross_revenue)}</div>
              <div className="kpi-sub">{fmtMoney(summary?.revenue_collected)} collected</div>
            </div>
            <div className="kpi-card">
              <div className="kpi-label">Avg Length of Stay</div>
              <div className="kpi-value">{summary?.avg_length_of_stay ?? '—'}<span style={{fontSize: 14}}> days</span></div>
              <div className="kpi-sub">Across all admissions</div>
            </div>
            <div className="kpi-card">
              <div className="kpi-label">Critical Case Rate</div>
              <div className="kpi-value">{summary?.critical_case_pct ?? '—'}%</div>
              <div className="kpi-sub">Of total admissions</div>
            </div>
            <div className="kpi-card">
              <div className="kpi-label">Doctors / Staff</div>
              <div className="kpi-value">{summary?.total_doctors ?? '—'} / {summary?.total_support_staff ?? '—'}</div>
              <div className="kpi-sub">Active workforce</div>
            </div>
          </div>

          {/* Row 1: Monthly Admissions + Gender */}
          <div className="grid-2" style={{ marginBottom: 18 }}>
            <div className="card card-pad">
              <div className="section-title">Monthly Admission Trend</div>
              <ResponsiveContainer width="100%" height={260}>
                <LineChart data={monthlyAdm}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E1E8EC" />
                  <XAxis dataKey="month_name" tick={{ fontSize: 11 }} tickFormatter={(v) => v?.slice(0,3)} />
                  <YAxis tick={{ fontSize: 11 }} />
                  <Tooltip />
                  <Line type="monotone" dataKey="admissions" stroke="#028090" strokeWidth={2.5} dot={{ r: 3 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>

            <div className="card card-pad">
              <div className="section-title">Patient Gender Split</div>
              <ResponsiveContainer width="100%" height={260}>
                <PieChart>
                  <Pie data={gender} dataKey="total_patients" nameKey="gender" cx="50%" cy="50%" outerRadius={85} label={({gender, pct_share}) => `${gender} ${pct_share}%`}>
                    {gender.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Row 2: Department Revenue + Severity */}
          <div className="grid-2" style={{ marginBottom: 18 }}>
            <div className="card card-pad">
              <div className="section-title">Top Departments by Revenue</div>
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={deptPerf} layout="vertical" margin={{ left: 20 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E1E8EC" />
                  <XAxis type="number" tick={{ fontSize: 11 }} tickFormatter={fmtMoney} />
                  <YAxis type="category" dataKey="department_name" tick={{ fontSize: 11 }} width={100} />
                  <Tooltip formatter={(v) => fmtMoney(v)} />
                  <Bar dataKey="total_revenue" fill="#028090" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>

            <div className="card card-pad">
              <div className="section-title">Admissions by Severity</div>
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={severity}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E1E8EC" />
                  <XAxis dataKey="severity" tick={{ fontSize: 11 }} />
                  <YAxis tick={{ fontSize: 11 }} />
                  <Tooltip />
                  <Bar dataKey="cases" radius={[4, 4, 0, 0]}>
                    {severity.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Row 3: Cost Breakdown + Top Diagnoses */}
          <div className="grid-2">
            <div className="card card-pad">
              <div className="section-title">Revenue Cost Breakdown</div>
              <ResponsiveContainer width="100%" height={240}>
                <PieChart>
                  <Pie data={costData} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={80} label={({ name }) => name}>
                    {costData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                  </Pie>
                  <Tooltip formatter={(v) => fmtMoney(v)} />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>

            <div className="card card-pad">
              <div className="section-title">Top Diagnoses by Case Count</div>
              <ResponsiveContainer width="100%" height={240}>
                <BarChart data={topDiagnoses} layout="vertical" margin={{ left: 10 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E1E8EC" />
                  <XAxis type="number" tick={{ fontSize: 11 }} />
                  <YAxis type="category" dataKey="diagnosis" tick={{ fontSize: 10 }} width={130} />
                  <Tooltip />
                  <Bar dataKey="cases" fill="#02C39A" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
