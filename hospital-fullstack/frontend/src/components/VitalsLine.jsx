// Signature motif: an ECG/vitals waveform used as a section divider
// throughout the app — ties every page back to the "hospital monitor" idea.
export default function VitalsLine({ color = "#02C39A", opacity = 0.85 }) {
  return (
    <svg
      className="vitals-divider"
      viewBox="0 0 1200 40"
      preserveAspectRatio="none"
      style={{ opacity }}
    >
      <polyline
        points="0,20 90,20 110,20 122,6 134,34 146,20 160,20 230,20 250,20 262,12 270,28 278,20 360,20 430,20 450,20 462,4 476,36 488,20 500,20 580,20 650,20 670,20 682,10 690,30 698,20 780,20 850,20 870,20 882,6 896,34 908,20 920,20 1000,20 1070,20 1090,20 1102,12 1110,28 1118,20 1200,20"
        fill="none"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}
