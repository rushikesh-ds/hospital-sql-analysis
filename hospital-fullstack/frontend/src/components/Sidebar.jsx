import { NavLink } from 'react-router-dom'
import {
  IconDashboard, IconPatients, IconDoctor, IconDept,
  IconAdmission, IconBilling, IconLab, IconStaff, IconPulse
} from './Icons'

const NAV_ITEMS = [
  { to: '/',            label: 'Dashboard',    icon: IconDashboard },
  { to: '/patients',    label: 'Patients',     icon: IconPatients },
  { to: '/doctors',     label: 'Doctors',      icon: IconDoctor },
  { to: '/departments', label: 'Departments',  icon: IconDept },
  { to: '/admissions',  label: 'Admissions',   icon: IconAdmission },
  { to: '/billing',     label: 'Billing',      icon: IconBilling },
  { to: '/lab-tests',   label: 'Lab Tests',    icon: IconLab },
  { to: '/staff',       label: 'Staff',        icon: IconStaff },
]

export default function Sidebar() {
  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <IconPulse className="pulse-icon" style={{ color: '#02C39A' }} />
        <span className="sidebar-brand-text">Medi<span>Track</span></span>
      </div>

      <nav className="sidebar-nav">
        {NAV_ITEMS.map(({ to, label, icon: Icon }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            className={({ isActive }) => `sidebar-link${isActive ? ' active' : ''}`}
          >
            <Icon className="icon" />
            {label}
          </NavLink>
        ))}
      </nav>

      <div className="sidebar-footer">
        hospital_db · MySQL 8.0
      </div>
    </aside>
  )
}
