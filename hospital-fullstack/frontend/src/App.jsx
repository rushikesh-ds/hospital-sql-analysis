import { Routes, Route } from 'react-router-dom'
import Sidebar from './components/Sidebar'
import Dashboard from './pages/Dashboard'
import PatientsPage from './pages/PatientsPage'
import DoctorsPage from './pages/DoctorsPage'
import DepartmentsPage from './pages/DepartmentsPage'
import AdmissionsPage from './pages/AdmissionsPage'
import BillingPage from './pages/BillingPage'
import LabTestsPage from './pages/LabTestsPage'
import StaffPage from './pages/StaffPage'

export default function App() {
  return (
    <div className="app-shell">
      <Sidebar />
      <main className="main-content">
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/patients" element={<PatientsPage />} />
          <Route path="/doctors" element={<DoctorsPage />} />
          <Route path="/departments" element={<DepartmentsPage />} />
          <Route path="/admissions" element={<AdmissionsPage />} />
          <Route path="/billing" element={<BillingPage />} />
          <Route path="/lab-tests" element={<LabTestsPage />} />
          <Route path="/staff" element={<StaffPage />} />
        </Routes>
      </main>
    </div>
  )
}
