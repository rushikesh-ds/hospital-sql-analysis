-- ============================================================
--  Hospital Data Analysis Project
--  File: 02_seed_data.sql
--  Description: Sample data for all tables (~200+ rows)
--  Dialect: MySQL 8.0+
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;
USE hospital_db;

-- ------------------------------------------------------------
-- DEPARTMENTS (no head yet; updated after doctors inserted)
-- ------------------------------------------------------------
INSERT INTO departments (department_name, location) VALUES
('Cardiology',          'Block A - Floor 2'),
('Neurology',           'Block A - Floor 3'),
('Orthopedics',         'Block B - Floor 1'),
('Pediatrics',          'Block B - Floor 2'),
('Oncology',            'Block C - Floor 1'),
('Emergency',           'Ground Floor'),
('General Medicine',    'Block A - Floor 1'),
('Gynecology',          'Block B - Floor 3'),
('Dermatology',         'Block C - Floor 2'),
('Psychiatry',          'Block D - Floor 1');

-- ------------------------------------------------------------
-- DOCTORS
-- ------------------------------------------------------------
INSERT INTO doctors (first_name, last_name, specialization, department_id, experience_yrs, email, phone, joining_date) VALUES
('Rajesh',   'Sharma',    'Cardiologist',         1, 15, 'r.sharma@hospital.com',    '9810001001', '2010-03-15'),
('Priya',    'Mehta',     'Cardiologist',         1,  8, 'p.mehta@hospital.com',     '9810001002', '2016-07-01'),
('Anil',     'Kumar',     'Neurologist',          2, 20, 'a.kumar@hospital.com',     '9810001003', '2004-01-10'),
('Sneha',    'Patel',     'Neurologist',          2, 10, 's.patel@hospital.com',     '9810001004', '2014-05-20'),
('Vikram',   'Singh',     'Orthopedic Surgeon',   3, 18, 'v.singh@hospital.com',     '9810001005', '2006-09-01'),
('Kavita',   'Rao',       'Orthopedic Surgeon',   3,  6, 'k.rao@hospital.com',       '9810001006', '2018-02-14'),
('Deepak',   'Joshi',     'Pediatrician',         4, 12, 'd.joshi@hospital.com',     '9810001007', '2012-11-30'),
('Sunita',   'Gupta',     'Pediatrician',         4,  9, 's.gupta@hospital.com',     '9810001008', '2015-06-15'),
('Rahul',    'Verma',     'Oncologist',           5, 22, 'r.verma@hospital.com',     '9810001009', '2002-04-01'),
('Anita',    'Desai',     'Oncologist',           5, 14, 'a.desai@hospital.com',     '9810001010', '2010-08-20'),
('Mohan',    'Tiwari',    'Emergency Medicine',   6, 11, 'm.tiwari@hospital.com',    '9810001011', '2013-01-05'),
('Rekha',    'Nair',      'Emergency Medicine',   6,  7, 'r.nair@hospital.com',      '9810001012', '2017-03-22'),
('Suresh',   'Pillai',    'General Physician',    7, 16, 's.pillai@hospital.com',    '9810001013', '2008-07-17'),
('Lakshmi',  'Iyer',      'Gynecologist',         8, 13, 'l.iyer@hospital.com',      '9810001014', '2011-10-10'),
('Pooja',    'Sinha',     'Dermatologist',        9,  5, 'p.sinha@hospital.com',     '9810001015', '2019-05-01');

-- Set department heads
UPDATE departments SET head_doctor_id =  1 WHERE department_id = 1;
UPDATE departments SET head_doctor_id =  3 WHERE department_id = 2;
UPDATE departments SET head_doctor_id =  5 WHERE department_id = 3;
UPDATE departments SET head_doctor_id =  7 WHERE department_id = 4;
UPDATE departments SET head_doctor_id =  9 WHERE department_id = 5;
UPDATE departments SET head_doctor_id = 11 WHERE department_id = 6;
UPDATE departments SET head_doctor_id = 13 WHERE department_id = 7;
UPDATE departments SET head_doctor_id = 14 WHERE department_id = 8;
UPDATE departments SET head_doctor_id = 15 WHERE department_id = 9;

-- ------------------------------------------------------------
-- PATIENTS (50 patients)
-- ------------------------------------------------------------
INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_group, phone, email) VALUES
('Amit',       'Shah',        '1978-04-12', 'Male',   'B+',  '9900001001', 'amit.shah@email.com'),
('Neha',       'Kapoor',      '1990-07-23', 'Female', 'O+',  '9900001002', 'neha.k@email.com'),
('Sanjay',     'Mishra',      '1965-11-05', 'Male',   'A+',  '9900001003', 'sanjay.m@email.com'),
('Rina',       'Dubey',       '1985-02-18', 'Female', 'AB+', '9900001004', 'rina.d@email.com'),
('Karan',      'Malhotra',    '2001-09-30', 'Male',   'O-',  '9900001005', 'karan.m@email.com'),
('Divya',      'Chopra',      '1972-06-14', 'Female', 'A-',  '9900001006', 'divya.c@email.com'),
('Manish',     'Agarwal',     '1958-03-22', 'Male',   'B-',  '9900001007', 'manish.a@email.com'),
('Priti',      'Saxena',      '1995-12-01', 'Female', 'B+',  '9900001008', 'priti.s@email.com'),
('Rohit',      'Pandey',      '1982-08-17', 'Male',   'AB-', '9900001009', 'rohit.p@email.com'),
('Ananya',     'Bose',        '2010-05-09', 'Female', 'O+',  '9900001010', 'ananya.b@email.com'),
('Vikas',      'Nanda',       '1969-01-28', 'Male',   'A+',  '9900001011', 'vikas.n@email.com'),
('Shweta',     'Tomar',       '1993-10-15', 'Female', 'B+',  '9900001012', 'shweta.t@email.com'),
('Aakash',     'Yadav',       '2005-03-04', 'Male',   'O+',  '9900001013', 'aakash.y@email.com'),
('Meera',      'Krishnan',    '1975-07-19', 'Female', 'A-',  '9900001014', 'meera.k@email.com'),
('Gaurav',     'Bhatt',       '1988-11-25', 'Male',   'AB+', '9900001015', 'gaurav.b@email.com'),
('Tanya',      'Chawla',      '1999-04-07', 'Female', 'O-',  '9900001016', 'tanya.c@email.com'),
('Ajay',       'Thakur',      '1961-09-12', 'Male',   'B+',  '9900001017', 'ajay.t@email.com'),
('Ruchi',      'Jain',        '1986-02-28', 'Female', 'A+',  '9900001018', 'ruchi.j@email.com'),
('Sunil',      'Rawat',       '1974-06-03', 'Male',   'O+',  '9900001019', 'sunil.r@email.com'),
('Pallavi',    'Menon',       '1991-08-21', 'Female', 'B-',  '9900001020', 'pallavi.m@email.com'),
('Deepesh',    'Trivedi',     '1967-12-14', 'Male',   'AB+', '9900001021', 'deepesh.t@email.com'),
('Shruti',     'Bajaj',       '2008-01-17', 'Female', 'O+',  '9900001022', 'shruti.b@email.com'),
('Naveen',     'Luthra',      '1980-05-29', 'Male',   'A+',  '9900001023', 'naveen.l@email.com'),
('Kavya',      'Reddy',       '1997-09-06', 'Female', 'B+',  '9900001024', 'kavya.r@email.com'),
('Harish',     'Mathur',      '1953-03-31', 'Male',   'AB-', '9900001025', 'harish.m@email.com'),
('Usha',       'Bansal',      '1971-11-08', 'Female', 'O+',  '9900001026', 'usha.b@email.com'),
('Tarun',      'Goel',        '1989-07-16', 'Male',   'A+',  '9900001027', 'tarun.g@email.com'),
('Simran',     'Arora',       '2003-04-24', 'Female', 'O-',  '9900001028', 'simran.a@email.com'),
('Brijesh',    'Srivastava',  '1964-10-02', 'Male',   'B+',  '9900001029', 'brijesh.s@email.com'),
('Madhuri',    'Patil',       '1983-02-11', 'Female', 'A-',  '9900001030', 'madhuri.p@email.com'),
('Lokesh',     'Tiwari',      '1977-06-20', 'Male',   'AB+', '9900001031', 'lokesh.t@email.com'),
('Geeta',      'Sharma',      '1960-09-27', 'Female', 'O+',  '9900001032', 'geeta.s@email.com'),
('Pranav',     'Dixit',       '1996-01-13', 'Male',   'B-',  '9900001033', 'pranav.d@email.com'),
('Aarti',      'Kulkarni',    '1987-05-22', 'Female', 'A+',  '9900001034', 'aarti.k@email.com'),
('Hemant',     'Soni',        '1970-08-04', 'Male',   'AB+', '9900001035', 'hemant.s@email.com'),
('Reena',      'Gaur',        '1994-12-19', 'Female', 'O+',  '9900001036', 'reena.g@email.com'),
('Sachin',     'Wagh',        '1976-04-08', 'Male',   'B+',  '9900001037', 'sachin.w@email.com'),
('Komal',      'Ahuja',       '2009-07-30', 'Female', 'A+',  '9900001038', 'komal.a@email.com'),
('Dinesh',     'Khanna',      '1956-11-15', 'Male',   'O-',  '9900001039', 'dinesh.k@email.com'),
('Vandana',    'Sethi',       '1984-03-07', 'Female', 'AB+', '9900001040', 'vandana.s@email.com'),
('Alok',       'Bajpai',      '1992-06-25', 'Male',   'B+',  '9900001041', 'alok.b@email.com'),
('Nidhi',      'Rastogi',     '1968-09-18', 'Female', 'A-',  '9900001042', 'nidhi.r@email.com'),
('Umesh',      'Chandra',     '1979-01-31', 'Male',   'O+',  '9900001043', 'umesh.c@email.com'),
('Poornima',   'Naik',        '1998-05-14', 'Female', 'B+',  '9900001044', 'poornima.n@email.com'),
('Girish',     'Kamat',       '1963-08-22', 'Male',   'AB+', '9900001045', 'girish.k@email.com'),
('Bhavna',     'Parikh',      '1990-02-03', 'Female', 'O+',  '9900001046', 'bhavna.p@email.com'),
('Santosh',    'More',        '1973-06-11', 'Male',   'A+',  '9900001047', 'santosh.m@email.com'),
('Leena',      'Sawant',      '2000-10-28', 'Female', 'B-',  '9900001048', 'leena.s@email.com'),
('Prakash',    'Hegde',       '1959-03-16', 'Male',   'O+',  '9900001049', 'prakash.h@email.com'),
('Varsha',     'Dalvi',       '1988-07-09', 'Female', 'AB-', '9900001050', 'varsha.d@email.com');

-- ------------------------------------------------------------
-- ADMISSIONS (60 records across 2023-2024)
-- ------------------------------------------------------------
INSERT INTO admissions (patient_id, doctor_id, department_id, admission_date, discharge_date, diagnosis, severity, admission_type, room_number, status) VALUES
( 1,  1, 1, '2023-01-05', '2023-01-12', 'Coronary Artery Disease',         'Severe',   'Emergency', '101', 'Discharged'),
( 2,  3, 2, '2023-01-10', '2023-01-20', 'Migraine with Aura',              'Moderate', 'Planned',   '201', 'Discharged'),
( 3,  5, 3, '2023-01-15', '2023-01-25', 'Knee Replacement',                'Moderate', 'Planned',   '301', 'Discharged'),
( 4,  7, 4, '2023-01-18', '2023-01-22', 'Acute Appendicitis (Child)',       'Severe',   'Emergency', '401', 'Discharged'),
( 5,  9, 5, '2023-02-01', '2023-02-20', 'Lung Cancer - Stage II',          'Critical', 'Referral',  '501', 'Discharged'),
( 6,  1, 1, '2023-02-05', '2023-02-10', 'Hypertensive Crisis',             'Severe',   'Emergency', '102', 'Discharged'),
( 7, 13, 7, '2023-02-08', '2023-02-14', 'Diabetes Type 2 Complication',    'Moderate', 'Planned',   '701', 'Discharged'),
( 8, 14, 8, '2023-02-12', '2023-02-16', 'Gestational Hypertension',        'Moderate', 'Planned',   '801', 'Discharged'),
( 9,  3, 2, '2023-02-20', '2023-03-02', 'Epilepsy Management',             'Severe',   'Planned',   '202', 'Discharged'),
(10,  7, 4, '2023-03-01', '2023-03-07', 'Viral Fever (Pediatric)',          'Mild',     'Emergency', '402', 'Discharged'),
(11,  1, 1, '2023-03-05', '2023-03-15', 'Heart Failure',                   'Critical', 'Emergency', '103', 'Discharged'),
(12,  5, 3, '2023-03-10', '2023-03-18', 'Spinal Disc Herniation',          'Moderate', 'Planned',   '302', 'Discharged'),
(13, 11, 6, '2023-03-12', '2023-03-13', 'Acute Trauma - Road Accident',    'Critical', 'Emergency', 'E01', 'Discharged'),
(14,  9, 5, '2023-03-18', '2023-04-10', 'Breast Cancer - Stage III',       'Critical', 'Referral',  '502', 'Discharged'),
(15,  3, 2, '2023-04-01', '2023-04-08', 'Alzheimer Early Stage',           'Moderate', 'Planned',   '203', 'Discharged'),
(16,  1, 1, '2023-04-05', '2023-04-12', 'Arrhythmia',                      'Severe',   'Emergency', '104', 'Discharged'),
(17, 13, 7, '2023-04-10', '2023-04-15', 'Typhoid Fever',                   'Moderate', 'Planned',   '702', 'Discharged'),
(18, 14, 8, '2023-04-15', '2023-04-19', 'Normal Delivery Complication',    'Moderate', 'Planned',   '802', 'Discharged'),
(19,  5, 3, '2023-05-01', '2023-05-10', 'Hip Fracture',                    'Severe',   'Emergency', '303', 'Discharged'),
(20,  7, 4, '2023-05-05', '2023-05-09', 'Asthma Attack (Child)',           'Severe',   'Emergency', '403', 'Discharged'),
(21,  9, 5, '2023-05-10', '2023-06-05', 'Lymphoma',                        'Critical', 'Referral',  '503', 'Discharged'),
(22,  3, 2, '2023-05-15', '2023-05-22', 'Stroke (Ischemic)',               'Critical', 'Emergency', '204', 'Discharged'),
(23, 11, 6, '2023-05-20', '2023-05-21', 'Burn Injury - Minor',             'Mild',     'Emergency', 'E02', 'Discharged'),
(24, 13, 7, '2023-06-01', '2023-06-07', 'Urinary Tract Infection',         'Mild',     'Planned',   '703', 'Discharged'),
(25,  1, 1, '2023-06-05', '2023-06-18', 'Open Heart Surgery',              'Critical', 'Planned',   '105', 'Discharged'),
(26,  5, 3, '2023-06-10', '2023-06-17', 'ACL Tear Repair',                 'Moderate', 'Planned',   '304', 'Discharged'),
(27,  7, 4, '2023-06-15', '2023-06-20', 'Pneumonia (Child)',                'Severe',   'Emergency', '404', 'Discharged'),
(28, 14, 8, '2023-07-01', '2023-07-05', 'Ovarian Cyst Removal',            'Moderate', 'Planned',   '803', 'Discharged'),
(29,  3, 2, '2023-07-08', '2023-07-16', 'Parkinsons Management',           'Moderate', 'Planned',   '205', 'Discharged'),
(30,  9, 5, '2023-07-12', '2023-08-15', 'Colon Cancer - Stage II',         'Severe',   'Referral',  '504', 'Discharged'),
(31, 11, 6, '2023-07-20', '2023-07-21', 'Fracture - Fall Injury',          'Moderate', 'Emergency', 'E03', 'Discharged'),
(32, 13, 7, '2023-08-01', '2023-08-08', 'Dengue Fever',                    'Severe',   'Emergency', '704', 'Discharged'),
(33,  1, 1, '2023-08-05', '2023-08-14', 'Pericarditis',                    'Severe',   'Planned',   '106', 'Discharged'),
(34,  5, 3, '2023-08-10', '2023-08-20', 'Shoulder Surgery',                'Moderate', 'Planned',   '305', 'Discharged'),
(35,  9, 5, '2023-09-01', '2023-10-01', 'Prostate Cancer - Stage III',     'Critical', 'Referral',  '505', 'Discharged'),
(36,  7, 4, '2023-09-05', '2023-09-10', 'Meningitis (Child)',               'Critical', 'Emergency', '405', 'Discharged'),
(37, 14, 8, '2023-09-10', '2023-09-14', 'Fibroid Uterus Surgery',          'Moderate', 'Planned',   '804', 'Discharged'),
(38,  3, 2, '2023-09-15', '2023-09-25', 'Brain Tumor Evaluation',          'Severe',   'Referral',  '206', 'Discharged'),
(39, 11, 6, '2023-10-01', '2023-10-02', 'Snake Bite Emergency',            'Critical', 'Emergency', 'E04', 'Discharged'),
(40, 13, 7, '2023-10-05', '2023-10-12', 'Cholera Treatment',               'Moderate', 'Emergency', '705', 'Discharged'),
(41,  1, 1, '2023-10-10', '2023-10-20', 'Valve Replacement Surgery',       'Critical', 'Planned',   '107', 'Discharged'),
(42,  5, 3, '2023-11-01', '2023-11-10', 'Knee Arthroscopy',                'Mild',     'Planned',   '306', 'Discharged'),
(43,  9, 5, '2023-11-05', '2023-12-10', 'Liver Cancer Chemotherapy',       'Critical', 'Referral',  '506', 'Discharged'),
(44,  7, 4, '2023-11-10', '2023-11-15', 'Chicken Pox (Pediatric)',         'Mild',     'Planned',   '406', 'Discharged'),
(45, 14, 8, '2023-11-20', '2023-11-24', 'Ectopic Pregnancy',               'Critical', 'Emergency', '805', 'Discharged'),
(46,  3, 2, '2023-12-01', '2023-12-10', 'Multiple Sclerosis Evaluation',   'Severe',   'Planned',   '207', 'Discharged'),
(47, 11, 6, '2023-12-05', '2023-12-06', 'Cardiac Arrest - Stabilized',     'Critical', 'Emergency', 'E05', 'Discharged'),
(48, 13, 7, '2023-12-10', '2023-12-18', 'Malaria Treatment',               'Moderate', 'Emergency', '706', 'Discharged'),
(49,  1, 1, '2024-01-08', '2024-01-17', 'Coronary Bypass Surgery',         'Critical', 'Planned',   '108', 'Discharged'),
(50,  5, 3, '2024-01-12', '2024-01-20', 'Spinal Fusion Surgery',           'Severe',   'Planned',   '307', 'Discharged'),
(51,  9, 5, '2024-02-01', '2024-03-15', 'Pancreatic Cancer Stage IV',      'Critical', 'Referral',  '507', 'Discharged'),
(52,  7, 4, '2024-02-10', '2024-02-15', 'RSV Bronchiolitis (Infant)',      'Severe',   'Emergency', '407', 'Discharged'),
(53, 14, 8, '2024-02-20', '2024-02-24', 'Endometriosis Surgery',           'Moderate', 'Planned',   '806', 'Discharged'),
(54,  3, 2, '2024-03-01', '2024-03-12', 'Cerebral Palsy Management',       'Moderate', 'Planned',   '208', 'Discharged'),
(55, 11, 6, '2024-03-10', '2024-03-11', 'Gunshot Wound - Emergency',       'Critical', 'Emergency', 'E06', 'Discharged'),
(56, 13, 7, '2024-04-05', '2024-04-12', 'Hypertension Management',         'Moderate', 'Planned',   '707', 'Discharged'),
(57,  1, 1, '2024-04-15', '2024-04-25', 'Heart Stent Placement',           'Severe',   'Planned',   '109', 'Discharged'),
(58,  5, 3, '2024-05-01', '2024-05-08', 'Bone Fracture - Wrist',           'Mild',     'Emergency', '308', 'Discharged'),
(59,  9, 5, '2024-05-10', NULL,         'Leukemia Treatment Ongoing',      'Critical', 'Referral',  '508', 'Admitted'),
(60, 14, 8, '2024-06-01', NULL,         'High-Risk Pregnancy Monitoring',  'Severe',   'Planned',   '807', 'Admitted');

-- ------------------------------------------------------------
-- BILLING
-- ------------------------------------------------------------
INSERT INTO billing (admission_id, patient_id, total_amount, medication_cost, surgery_cost, consultation_fee, room_charges, insurance_covered, amount_paid, payment_status, payment_method, bill_date) VALUES
( 1,  1,  85000,  8000,  45000, 3000, 14000,  50000,  35000, 'Partial',  'Insurance',     '2023-01-12'),
( 2,  2,  32000,  5000,      0, 4000,  8000,  20000,  12000, 'Partial',  'Insurance',     '2023-01-20'),
( 3,  3, 180000,  6000, 130000, 3000, 16000,  90000,  90000, 'Paid',     'Insurance',     '2023-01-25'),
( 4,  4,  55000,  7000,  32000, 3500, 10000,  30000,  25000, 'Partial',  'Insurance',     '2023-01-22'),
( 5,  5, 250000, 80000, 100000, 5000, 38000, 150000, 100000, 'Partial',  'Insurance',     '2023-02-20'),
( 6,  6,  42000,  5000,      0, 3500, 12000,      0,  42000, 'Paid',     'Card',          '2023-02-10'),
( 7,  7,  28000,  8000,      0, 3000,  8000,  15000,  13000, 'Partial',  'Insurance',     '2023-02-14'),
( 8,  8,  35000,  4000,      0, 3500, 10000,  20000,  15000, 'Partial',  'Insurance',     '2023-02-16'),
( 9,  9,  68000, 12000,      0, 4500, 20000,  40000,  28000, 'Partial',  'Insurance',     '2023-03-02'),
(10, 10,  18000,  4000,      0, 2500,  5000,   8000,  10000, 'Paid',     'Cash',          '2023-03-07'),
(11, 11, 120000, 15000,  60000, 5000, 25000,  80000,  40000, 'Partial',  'Insurance',     '2023-03-15'),
(12, 12,  95000,  5000,  65000, 3500, 14000,  60000,  35000, 'Partial',  'Insurance',     '2023-03-18'),
(13, 13,  22000,  6000,      0, 3000,  8000,      0,  22000, 'Paid',     'Card',          '2023-03-13'),
(14, 14, 320000, 90000, 150000, 6000, 50000, 200000, 120000, 'Partial',  'Insurance',     '2023-04-10'),
(15, 15,  40000,  9000,      0, 4500, 12000,  25000,  15000, 'Partial',  'Insurance',     '2023-04-08'),
(16, 16,  58000,  7000,      0, 4000, 15000,  35000,  23000, 'Partial',  'Insurance',     '2023-04-12'),
(17, 17,  24000,  6000,      0, 2500,  7000,  10000,  14000, 'Paid',     'UPI',           '2023-04-15'),
(18, 18,  38000,  5000,      0, 4000, 11000,  20000,  18000, 'Partial',  'Insurance',     '2023-04-19'),
(19, 19,  75000,  6000,  45000, 3500, 12000,  40000,  35000, 'Partial',  'Insurance',     '2023-05-10'),
(20, 20,  26000,  5000,      0, 2500,  8000,  15000,  11000, 'Partial',  'Insurance',     '2023-05-09'),
(21, 21, 280000, 100000, 120000, 6000, 40000, 180000, 100000, 'Partial', 'Insurance',     '2023-06-05'),
(22, 22,  95000, 10000,  55000, 5000, 18000,  60000,  35000, 'Partial',  'Insurance',     '2023-05-22'),
(23, 23,  15000,  3000,      0, 2000,  5000,      0,  15000, 'Paid',     'Cash',          '2023-05-21'),
(24, 24,  16000,  5000,      0, 2500,  4000,   8000,   8000, 'Paid',     'UPI',           '2023-06-07'),
(25, 25, 350000, 20000, 260000, 7000, 45000, 250000, 100000, 'Partial',  'Insurance',     '2023-06-18'),
(26, 26,  85000,  4000,  60000, 3500, 14000,  50000,  35000, 'Partial',  'Insurance',     '2023-06-17'),
(27, 27,  32000,  7000,      0, 3000,  9000,  15000,  17000, 'Paid',     'Card',          '2023-06-20'),
(28, 28,  48000,  5000,  28000, 3500, 10000,  30000,  18000, 'Partial',  'Insurance',     '2023-07-05'),
(29, 29,  44000, 10000,      0, 4500, 14000,  25000,  19000, 'Partial',  'Insurance',     '2023-07-16'),
(30, 30, 310000, 110000, 130000, 6000, 48000, 200000, 110000, 'Partial', 'Insurance',     '2023-08-15'),
(31, 31,  20000,  4000,      0, 2500,  6000,      0,  20000, 'Paid',     'Cash',          '2023-07-21'),
(32, 32,  38000,  8000,      0, 3500, 11000,  20000,  18000, 'Paid',     'UPI',           '2023-08-08'),
(33, 33,  72000,  9000,  38000, 4000, 15000,  45000,  27000, 'Partial',  'Insurance',     '2023-08-14'),
(34, 34,  78000,  5000,  52000, 3500, 14000,  50000,  28000, 'Partial',  'Insurance',     '2023-08-20'),
(35, 35, 295000, 95000, 140000, 6000, 45000, 200000,  95000, 'Partial',  'Insurance',     '2023-10-01'),
(36, 36,  65000, 12000,  28000, 4000, 15000,  40000,  25000, 'Partial',  'Insurance',     '2023-09-10'),
(37, 37,  52000,  5000,  32000, 3500, 10000,  30000,  22000, 'Partial',  'Insurance',     '2023-09-14'),
(38, 38,  88000, 10000,  50000, 5000, 20000,  55000,  33000, 'Partial',  'Insurance',     '2023-09-25'),
(39, 39,  25000,  8000,      0, 3000,  8000,      0,  25000, 'Paid',     'Cash',          '2023-10-02'),
(40, 40,  22000,  7000,      0, 2500,  7000,  10000,  12000, 'Paid',     'UPI',           '2023-10-12'),
(41, 41, 280000, 18000, 210000, 7000, 40000, 200000,  80000, 'Partial',  'Insurance',     '2023-10-20'),
(42, 42,  42000,  3000,  28000, 3000,  8000,  25000,  17000, 'Paid',     'Card',          '2023-11-10'),
(43, 43, 420000, 180000, 160000, 7000, 55000, 300000, 120000, 'Partial', 'Insurance',     '2023-12-10'),
(44, 44,  12000,  4000,      0, 2000,  4000,   5000,   7000, 'Paid',     'Cash',          '2023-11-15'),
(45, 45,  68000,  8000,  42000, 4000, 12000,  40000,  28000, 'Partial',  'Insurance',     '2023-11-24'),
(46, 46,  74000, 12000,  40000, 4500, 16000,  50000,  24000, 'Partial',  'Insurance',     '2023-12-10'),
(47, 47,  30000,  8000,      0, 3500, 10000,      0,  30000, 'Paid',     'Card',          '2023-12-06'),
(48, 48,  26000,  8000,      0, 2500,  8000,  12000,  14000, 'Paid',     'UPI',           '2023-12-18'),
(49, 49, 310000, 20000, 230000, 7000, 45000, 220000,  90000, 'Partial',  'Insurance',     '2024-01-17'),
(50, 50, 195000, 15000, 140000, 5000, 30000, 120000,  75000, 'Partial',  'Insurance',     '2024-01-20'),
(51, 51, 480000, 200000, 180000, 8000, 70000, 350000, 130000, 'Partial', 'Insurance',     '2024-03-15'),
(52, 52,  42000,  9000,      0, 3500, 12000,  25000,  17000, 'Partial',  'Insurance',     '2024-02-15'),
(53, 53,  55000,  5000,  35000, 3500,  9000,  35000,  20000, 'Paid',     'Insurance',     '2024-02-24'),
(54, 54,  48000, 10000,      0, 4500, 14000,  30000,  18000, 'Partial',  'Insurance',     '2024-03-12'),
(55, 55,  35000,  8000,      0, 3500, 12000,      0,  35000, 'Paid',     'Cash',          '2024-03-11'),
(56, 56,  24000,  6000,      0, 3000,  7000,  12000,  12000, 'Paid',     'UPI',           '2024-04-12'),
(57, 57, 145000, 12000,  95000, 5000, 25000,  90000,  55000, 'Partial',  'Insurance',     '2024-04-25'),
(58, 58,  22000,  3000,      0, 2500,  7000,  10000,  12000, 'Paid',     'Card',          '2024-05-08');

-- ------------------------------------------------------------
-- MEDICATIONS (sample - one per admission)
-- ------------------------------------------------------------
INSERT INTO medications (admission_id, drug_name, dosage, frequency, start_date, end_date, prescribed_by) VALUES
( 1, 'Aspirin',          '75mg',   'Once daily',     '2023-01-05', '2023-01-12',  1),
( 1, 'Atorvastatin',     '40mg',   'Once at night',  '2023-01-05', '2023-01-12',  1),
( 2, 'Topiramate',       '50mg',   'Twice daily',    '2023-01-10', '2023-01-20',  3),
( 5, 'Carboplatin',      '400mg',  'Weekly IV',      '2023-02-01', '2023-02-20',  9),
( 5, 'Paclitaxel',       '175mg',  'Weekly IV',      '2023-02-01', '2023-02-20',  9),
( 7, 'Metformin',        '500mg',  'Twice daily',    '2023-02-08', '2023-02-14', 13),
( 9, 'Levetiracetam',    '500mg',  'Twice daily',    '2023-02-20', '2023-03-02',  3),
(11, 'Furosemide',       '40mg',   'Once daily',     '2023-03-05', '2023-03-15',  1),
(14, 'Doxorubicin',      '60mg',   'Monthly IV',     '2023-03-18', '2023-04-10',  9),
(21, 'Rituximab',        '375mg',  'Weekly IV',      '2023-05-10', '2023-06-05',  9),
(22, 'Alteplase',        '90mg',   'Single dose IV', '2023-05-15', '2023-05-15',  3),
(25, 'Warfarin',         '5mg',    'Once daily',     '2023-06-05', '2023-06-18',  1),
(30, 'Capecitabine',     '1250mg', 'Twice daily',    '2023-07-12', '2023-08-15',  9),
(32, 'IV Fluids',        '1L NS',  'Continuous',     '2023-08-01', '2023-08-08', 13),
(36, 'Ceftriaxone',      '2g',     'Once daily IV',  '2023-09-05', '2023-09-10',  7),
(41, 'Heparin',          '5000U',  'Every 8hrs IV',  '2023-10-10', '2023-10-20',  1),
(43, 'Gemcitabine',      '1000mg', 'Weekly IV',      '2023-11-05', '2023-12-10',  9),
(48, 'Chloroquine',      '500mg',  'Once daily',     '2023-12-10', '2023-12-18', 13),
(49, 'Clopidogrel',      '75mg',   'Once daily',     '2024-01-08', '2024-01-17',  1),
(51, 'Erlotinib',        '150mg',  'Once daily',     '2024-02-01', NULL,           9);

-- ------------------------------------------------------------
-- LAB TESTS
-- ------------------------------------------------------------
INSERT INTO lab_tests (admission_id, test_name, test_date, result, result_status, cost) VALUES
( 1, 'ECG',                   '2023-01-05', 'ST elevation noted',      'Abnormal', 1500),
( 1, 'Troponin I',            '2023-01-05', '2.8 ng/mL (High)',        'Critical', 1200),
( 1, 'Lipid Profile',         '2023-01-06', 'LDL 185 mg/dL',          'Abnormal', 800),
( 2, 'MRI Brain',             '2023-01-10', 'No structural anomaly',   'Normal',   4500),
( 5, 'CT Chest',              '2023-02-01', 'Mass in right lung 3cm',  'Critical', 5000),
( 5, 'Biopsy Lung',           '2023-02-02', 'Adenocarcinoma confirmed','Abnormal', 3500),
( 7, 'HbA1c',                 '2023-02-08', '9.2% (High)',             'Abnormal', 600),
( 7, 'Fasting Blood Sugar',   '2023-02-08', '280 mg/dL (High)',        'Critical', 300),
(11, 'Echocardiogram',        '2023-03-05', 'EF 30% (Low)',            'Critical', 3500),
(11, 'BNP Levels',            '2023-03-05', '1200 pg/mL (High)',       'Critical', 1500),
(14, 'Mammography',           '2023-03-18', 'Mass 4cm right breast',   'Abnormal', 3000),
(14, 'HER2 Status',           '2023-03-19', 'HER2 Positive',           'Abnormal', 4000),
(22, 'CT Brain',              '2023-05-15', 'Left MCA territory infarct','Critical',5000),
(22, 'MRI Brain',             '2023-05-15', 'Acute ischemic stroke',   'Critical', 4500),
(25, 'Coronary Angiography',  '2023-06-06', 'Triple vessel disease',   'Critical', 8000),
(30, 'Colonoscopy',           '2023-07-12', 'Polyp in sigmoid colon',  'Abnormal', 4000),
(30, 'CEA Marker',            '2023-07-12', '28 ng/mL (High)',         'Abnormal', 1000),
(32, 'NS1 Antigen',           '2023-08-01', 'Dengue Positive',         'Abnormal', 800),
(32, 'CBC',                   '2023-08-02', 'Platelet 40000 (Low)',    'Critical', 500),
(35, 'PSA',                   '2023-09-01', '45 ng/mL (High)',         'Critical', 900),
(36, 'Lumbar Puncture',       '2023-09-05', 'Bacterial Meningitis',    'Critical', 2500),
(41, 'Cardiac Catheterization','2023-10-10','Severe mitral regurgitation','Critical',9000),
(43, 'AFP Marker',            '2023-11-05', '1200 IU/mL (High)',       'Critical', 1200),
(43, 'MRI Abdomen',           '2023-11-05', 'Hepatocellular carcinoma','Critical', 5000),
(47, 'ABG',                   '2023-12-05', 'pH 7.1 - Acidosis',       'Critical', 1000),
(49, 'Coronary CTA',          '2024-01-08', '90% LAD occlusion',       'Critical', 7000),
(51, 'CA 19-9',               '2024-02-01', '890 U/mL (Very High)',    'Critical', 1100),
(57, 'Cardiac Stress Test',   '2024-04-15', 'Positive - Ischemia',     'Abnormal', 3500);

-- ------------------------------------------------------------
-- STAFF
-- ------------------------------------------------------------
INSERT INTO staff (first_name, last_name, role, department_id, shift, joining_date, salary) VALUES
('Sunanda',  'Pillai',   'Nurse',        1, 'Morning',  '2018-03-01', 42000),
('Ramesh',   'Nair',     'Nurse',        2, 'Evening',  '2019-07-15', 40000),
('Deepa',    'Varma',    'Nurse',        3, 'Night',    '2020-01-10', 39000),
('Asha',     'Krishnan', 'Nurse',        4, 'Morning',  '2017-06-20', 43000),
('Monika',   'Shah',     'Nurse',        5, 'Evening',  '2021-03-05', 38000),
('Rajan',    'Mehta',    'Technician',   1, 'Morning',  '2016-09-12', 35000),
('Pradeep',  'Jain',     'Technician',   2, 'Evening',  '2018-11-22', 34000),
('Sonal',    'Bhatt',    'Technician',   6, 'Night',    '2019-04-18', 33000),
('Kavita',   'Desai',    'Admin',        7, 'Morning',  '2015-02-28', 30000),
('Prakash',  'Soni',     'Admin',        6, 'Morning',  '2014-08-14', 32000),
('Meenakshi','Pandey',   'Pharmacist',   7, 'Morning',  '2017-10-01', 36000),
('Sudhir',   'Tripathi', 'Pharmacist',   5, 'Evening',  '2020-06-15', 35000),
('Ravi',     'Walke',    'Ward Boy',     3, 'Night',    '2022-01-20', 18000),
('Lata',     'Gore',     'Ward Boy',     4, 'Morning',  '2021-09-10', 18000),
('Nilesh',   'Patil',    'Nurse',        6, 'Night',    '2016-12-05', 44000),
('Varsha',   'Shinde',   'Nurse',        8, 'Morning',  '2020-03-22', 41000),
('Ganesh',   'Mane',     'Technician',   5, 'Morning',  '2019-08-08', 35000),
('Jyoti',    'Kadam',    'Admin',        8, 'Evening',  '2018-05-30', 29000),
('Ajit',     'Dhole',    'Ward Boy',     6, 'Morning',  '2023-02-14', 18000),
('Smita',    'Kulkarni', 'Pharmacist',   1, 'Morning',  '2016-07-19', 37000);
