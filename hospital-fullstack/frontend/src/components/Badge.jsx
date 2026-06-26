const SEVERITY_CLASS = {
  Mild: 'badge-mild',
  Moderate: 'badge-moderate',
  Severe: 'badge-severe',
  Critical: 'badge-critical',
}

const PAYMENT_CLASS = {
  Paid: 'badge-paid',
  Partial: 'badge-partial',
  Pending: 'badge-pending',
  Waived: 'badge-paid',
}

export function SeverityBadge({ value }) {
  return <span className={`badge ${SEVERITY_CLASS[value] || 'badge-mild'}`}>{value}</span>
}

export function PaymentBadge({ value }) {
  return <span className={`badge ${PAYMENT_CLASS[value] || 'badge-pending'}`}>{value}</span>
}
