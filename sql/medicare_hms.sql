CREATE DATABASE IF NOT EXISTS medicare_db;
USE medicare_db;

CREATE TABLE department (
    dept_id    INT PRIMARY KEY,
    dept_name  VARCHAR(50) NOT NULL UNIQUE,
    location   VARCHAR(50) NOT NULL,
    phone      VARCHAR(15)
);

CREATE TABLE doctor (
    doctor_id         INT PRIMARY KEY,
    first_name        VARCHAR(30) NOT NULL,
    last_name         VARCHAR(30) NOT NULL,
    specialization    VARCHAR(50) NOT NULL,
    phone             VARCHAR(15) UNIQUE,
    salary            DECIMAL(10,2) NOT NULL,
    consultation_fee  DECIMAL(8,2) NOT NULL,
    joining_date      DATE NOT NULL,
    dept_id           INT NOT NULL,
    CONSTRAINT chk_doctor_salary CHECK (salary > 0),
    CONSTRAINT chk_doctor_fee    CHECK (consultation_fee >= 0),
    CONSTRAINT fk_doctor_dept FOREIGN KEY (dept_id)
        REFERENCES department(dept_id)
);

CREATE TABLE patient (
    patient_id     INT PRIMARY KEY,
    first_name     VARCHAR(30) NOT NULL,
    last_name      VARCHAR(30) NOT NULL,
    gender         CHAR(1) NOT NULL,
    date_of_birth  DATE NOT NULL,
    phone          VARCHAR(15) UNIQUE,
    city           VARCHAR(40),
    blood_group    VARCHAR(3),
    CONSTRAINT chk_patient_gender CHECK (gender IN ('M','F','O'))
);

CREATE TABLE appointment (
    appointment_id  INT PRIMARY KEY,
    patient_id      INT NOT NULL,
    doctor_id       INT NOT NULL,
    appt_date       DATE NOT NULL,
    reason          VARCHAR(100),
    status          VARCHAR(10) NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT chk_appt_status CHECK
        (status IN ('Scheduled','Completed','Cancelled')),
    CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),
    CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id)
        REFERENCES doctor(doctor_id)
);

CREATE TABLE room (
    room_id         INT PRIMARY KEY,
    room_type       VARCHAR(20) NOT NULL,
    charge_per_day  DECIMAL(8,2) NOT NULL,
    is_available    CHAR(1) NOT NULL DEFAULT 'Y',
    CONSTRAINT chk_room_type CHECK
        (room_type IN ('General','Semi-Private','Private','ICU')),
    CONSTRAINT chk_room_charge CHECK (charge_per_day > 0)
);

CREATE TABLE admission (
    admission_id    INT PRIMARY KEY,
    patient_id      INT NOT NULL,
    room_id         INT NOT NULL,
    admit_date      DATE NOT NULL,
    discharge_date  DATE,
    diagnosis       VARCHAR(100),
    CONSTRAINT chk_admission_dates CHECK
        (discharge_date IS NULL OR discharge_date >= admit_date),
    CONSTRAINT fk_adm_patient FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),
    CONSTRAINT fk_adm_room FOREIGN KEY (room_id)
        REFERENCES room(room_id)
);

CREATE TABLE medicine (
    medicine_id    INT PRIMARY KEY,
    medicine_name  VARCHAR(50) NOT NULL UNIQUE,
    manufacturer   VARCHAR(50),
    unit_price     DECIMAL(8,2) NOT NULL,
    stock_qty      INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_med_price CHECK (unit_price >= 0),
    CONSTRAINT chk_med_stock CHECK (stock_qty >= 0)
);

CREATE TABLE prescription (
    prescription_id  INT PRIMARY KEY,
    appointment_id   INT NOT NULL,
    medicine_id      INT NOT NULL,
    dosage           VARCHAR(30) NOT NULL,
    duration_days    INT NOT NULL,
    CONSTRAINT chk_presc_days CHECK (duration_days > 0),
    CONSTRAINT fk_presc_appt FOREIGN KEY (appointment_id)
        REFERENCES appointment(appointment_id) ON DELETE CASCADE,
    CONSTRAINT fk_presc_med FOREIGN KEY (medicine_id)
        REFERENCES medicine(medicine_id)
);

CREATE TABLE bill (
    bill_id         INT PRIMARY KEY,
    patient_id      INT NOT NULL,
    bill_date       DATE NOT NULL,
    total_amount    DECIMAL(10,2) NOT NULL,
    payment_mode    VARCHAR(15),
    payment_status  VARCHAR(10) NOT NULL DEFAULT 'Pending',
    CONSTRAINT chk_bill_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_bill_status CHECK
        (payment_status IN ('Paid','Pending','Partial')),
    CONSTRAINT fk_bill_patient FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id)
);

ALTER TABLE patient ADD COLUMN email VARCHAR(60);

CREATE INDEX idx_patient_city ON patient(city);
CREATE INDEX idx_appt_date ON appointment(appt_date);

CREATE TABLE temp_feedback (
    feedback_id  INT PRIMARY KEY,
    comments     VARCHAR(100)
);
TRUNCATE TABLE temp_feedback;
DROP TABLE temp_feedback;


INSERT INTO department VALUES
(1, 'Cardiology',       'Block A', '0172-4001001'),
(2, 'Neurology',        'Block B', '0172-4001002'),
(3, 'Orthopedics',      'Block C', '0172-4001003'),
(4, 'Pediatrics',       'Block A', '0172-4001004'),
(5, 'General Medicine', 'Block D', '0172-4001005'),
(6, 'Dermatology',      'Block B', '0172-4001006');

INSERT INTO doctor VALUES
(101,'Rajesh','Kumar','Cardiologist','9876500101',150000,800,'2015-06-12',1),
(102,'Anjali','Sharma','Neurologist','9876500102',140000,900,'2017-03-20',2),
(103,'Vikram','Singh','Orthopedic Surgeon','9876500103',135000,700,'2016-08-01',3),
(104,'Meera','Nair','Pediatrician','9876500104',95000,500,'2019-01-15',4),
(105,'Sandeep','Verma','General Physician','9876500105',85000,400,'2020-07-10',5),
(106,'Priya','Malhotra','Dermatologist','9876500106',90000,600,'2021-02-25',6),
(107,'Arvind','Chauhan','Cardiologist','9876500107',120000,750,'2018-11-05',1),
(108,'Neha','Gupta','General Physician','9876500108',80000,400,'2022-04-18',5);

INSERT INTO patient
(patient_id, first_name, last_name, gender, date_of_birth, phone, city, blood_group)
VALUES
(1, 'Amit',   'Kapoor',    'M', '1985-04-12', '9812300001', 'Chandigarh', 'B+'),
(2, 'Sneha',  'Reddy',     'F', '1992-09-30', '9812300002', 'Mohali',     'O+'),
(3, 'Rohan',  'Mehta',     'M', '2015-02-18', '9812300003', 'Panchkula',  'A+'),
(4, 'Pooja',  'Yadav',     'F', '1978-12-05', '9812300004', 'Rewari',     'B-'),
(5, 'Karan',  'Malhotra',  'M', '1969-07-21', '9812300005', 'Ambala',     'AB+'),
(6, 'Simran', 'Kaur',      'F', '2000-01-14', '9812300006', 'Chandigarh', 'O-'),
(7, 'Deepak', 'Joshi',     'M', '1958-03-09', '9812300007', 'Mohali',     'A-'),
(8, 'Kavita', 'Bansal',    'F', '1988-11-27', '9812300008', 'Panchkula',  'B+'),
(9, 'Harsh',  'Vardhan',   'M', '2010-06-02', '9812300009', 'Rewari',     'O+'),
(10,'Anita',  'Choudhary', 'F', '1975-05-16', '9812300010', 'Ambala',     'A+'),
(11,'Manish', 'Tiwari',    'M', '1995-08-08', '9812300011', 'Chandigarh', 'B+'),
(12,'Ritu',   'Saxena',    'F', '1983-10-23', '9812300012', 'Mohali',     'AB-');

INSERT INTO room (room_id, room_type, charge_per_day) VALUES
(1, 'General',      1500),
(2, 'General',      1500),
(3, 'Semi-Private', 2500),
(4, 'Private',      4000),
(5, 'Private',      4000),
(6, 'ICU',          8000);

INSERT INTO appointment VALUES
(1,  1, 101, '2026-09-05', 'Chest pain',            'Completed'),
(2,  5, 107, '2026-09-10', 'Severe chest pain',     'Completed'),
(3,  7, 102, '2026-09-20', 'Sudden weakness',       'Completed'),
(4,  3, 104, '2026-09-22', 'Fever and cough',       'Completed'),
(5,  6, 106, '2026-09-25', 'Skin allergy',          'Completed'),
(6,  4, 103, '2026-10-02', 'Leg injury',            'Completed'),
(7,  11,105, '2026-10-05', 'Seasonal flu',          'Completed'),
(8,  8, 102, '2026-10-12', 'Recurring migraine',    'Completed'),
(9,  2, 108, '2026-10-18', 'High fever',            'Completed'),
(10, 9, 104, '2026-10-25', 'Vaccination check',     'Completed'),
(11, 12,106, '2026-10-30', 'Skin rash',             'Cancelled'),
(12, 10,105, '2026-11-01', 'Breathing difficulty',  'Completed'),
(13, 12,101, '2026-11-04', 'Routine heart checkup', 'Completed'),
(14, 1, 107, '2026-11-10', 'Follow-up visit',       'Scheduled'),
(15, 6, 106, '2026-11-12', 'Skin allergy follow-up','Scheduled');

INSERT INTO admission VALUES
(1, 5,  6, '2026-09-10', '2026-09-15', 'Acute myocardial infarction'),
(2, 7,  4, '2026-09-20', '2026-09-26', 'Ischemic stroke'),
(3, 4,  3, '2026-10-02', '2026-10-05', 'Fractured tibia'),
(4, 2,  1, '2026-10-18', '2026-10-20', 'Dengue fever'),
(5, 10, 5, '2026-11-01', NULL,         'Pneumonia');

INSERT INTO medicine VALUES
(1, 'Paracetamol',   'Cipla',       5.00,  500),
(2, 'Amoxicillin',   'Sun Pharma', 12.00,  300),
(3, 'Cetirizine',    'Zydus',       4.00,  400),
(4, 'Atorvastatin',  'Lupin',      18.50,  250),
(5, 'Aspirin',       'Cipla',       3.00,  600),
(6, 'Ibuprofen',     'Dr. Reddys',  6.00,   80),
(7, 'Pantoprazole',  'Sun Pharma',  9.50,  350),
(8, 'Azithromycin',  'Zydus',      25.00,   60),
(9, 'Amlodipine',    'Lupin',       8.00,  220);

INSERT INTO prescription VALUES
(1,  1, 4, 'Once daily',   30),
(2,  1, 5, 'Once daily',   30),
(3,  2, 4, 'Once daily',   30),
(4,  2, 9, 'Once daily',   30),
(5,  2, 5, 'Once daily',   30),
(6,  3, 5, 'Once daily',   30),
(7,  4, 1, 'Thrice daily',  5),
(8,  4, 2, 'Twice daily',   5),
(9,  5, 3, 'Once daily',    7),
(10, 6, 6, 'Twice daily',   7),
(11, 6, 7, 'Once daily',    7),
(12, 7, 1, 'Thrice daily',  3),
(13, 7, 3, 'Once daily',    5),
(14, 8, 6, 'Twice daily',   5),
(15, 9, 1, 'Thrice daily',  5),
(16, 12,8, 'Once daily',    3),
(17, 12,7, 'Once daily',    5),
(18, 13,9, 'Once daily',   30);

INSERT INTO bill VALUES
(1,  5, '2026-09-15', 48500.00, 'Card',      'Paid'),
(2,  7, '2026-09-26', 36200.00, 'Insurance', 'Paid'),
(3,  4, '2026-10-05', 17850.00, 'UPI',       'Paid'),
(4,  2, '2026-10-20',  6450.00, 'Cash',      'Paid'),
(5,  1, '2026-09-05',  1250.00, 'UPI',       'Paid'),
(6,  3, '2026-09-22',   650.00, 'Cash',      'Paid'),
(7,  6, '2026-09-25',   750.00, 'UPI',       'Paid'),
(8,  11,'2026-10-05',   550.00, 'Cash',      'Paid'),
(9,  8, '2026-10-12',  1100.00, 'Card',      'Partial'),
(10, 9, '2026-10-25',   500.00, 'Cash',      'Paid'),
(11, 12,'2026-11-04',   950.00, 'UPI',       'Paid'),
(12, 10,'2026-11-01',  2400.00, NULL,        'Pending');



UPDATE room SET is_available = 'N' WHERE room_id = 5;

UPDATE doctor
SET consultation_fee = consultation_fee + 100
WHERE dept_id = 5;

INSERT INTO appointment (appointment_id, patient_id, doctor_id, appt_date, reason)
VALUES (16, 9, 108, '2026-11-15', 'Fever review');

SELECT appointment_id, appt_date, status FROM appointment
WHERE appointment_id = 16;

DELETE FROM appointment WHERE appointment_id = 16;

SELECT patient_id, first_name, last_name, city, blood_group
FROM patient
WHERE blood_group = 'B+';

START TRANSACTION;

INSERT INTO bill VALUES (13, 3, '2026-11-07', 700.00, 'Cash', 'Paid');
SAVEPOINT after_bill;

UPDATE medicine SET stock_qty = stock_qty - 100 WHERE medicine_id = 1;
SELECT medicine_id, medicine_name, stock_qty FROM medicine WHERE medicine_id = 1;

ROLLBACK TO after_bill;
SELECT medicine_id, medicine_name, stock_qty FROM medicine WHERE medicine_id = 1;

COMMIT;

START TRANSACTION;
DELETE FROM prescription WHERE prescription_id > 0;
SELECT COUNT(*) AS rows_inside_transaction FROM prescription;
ROLLBACK;
SELECT COUNT(*) AS rows_after_rollback FROM prescription;


-- Query 1: Doctors ordered by salary
SELECT doctor_id,
       CONCAT(first_name, ' ', last_name) AS doctor_name,
       specialization, salary
FROM doctor
ORDER BY salary DESC;

-- Query 2: Patients from selected cities (IN)
SELECT patient_id, first_name, last_name, city
FROM patient
WHERE city IN ('Chandigarh', 'Mohali')
ORDER BY city, patient_id;

-- Query 3: Appointments of October 2026 (BETWEEN)
SELECT appointment_id, patient_id, doctor_id, appt_date, reason
FROM appointment
WHERE appt_date BETWEEN '2026-10-01' AND '2026-10-31'
ORDER BY appt_date;

-- Query 4: Medicines starting with A (LIKE)
SELECT medicine_id, medicine_name, manufacturer, unit_price
FROM medicine
WHERE medicine_name LIKE 'A%';

-- Query 5: Bills that are not fully paid
SELECT bill_id, patient_id, bill_date, total_amount,
       payment_mode, payment_status
FROM bill
WHERE payment_status <> 'Paid';

-- Query 6: Number of patients in each city
SELECT city, COUNT(*) AS total_patients
FROM patient
GROUP BY city
ORDER BY total_patients DESC, city;

-- Query 7: Salary statistics of all doctors
SELECT COUNT(*) AS total_doctors,
       SUM(salary) AS total_salary,
       ROUND(AVG(salary), 2) AS avg_salary,
       MIN(salary) AS min_salary,
       MAX(salary) AS max_salary
FROM doctor;

-- Query 8: Doctors with two or more appointments (HAVING)
SELECT doctor_id, COUNT(*) AS total_appointments
FROM appointment
GROUP BY doctor_id
HAVING COUNT(*) >= 2
ORDER BY total_appointments DESC, doctor_id;

-- Query 9: Revenue collected by payment mode
SELECT payment_mode,
       COUNT(*) AS bills,
       SUM(total_amount) AS total_revenue
FROM bill
WHERE payment_mode IS NOT NULL
GROUP BY payment_mode
ORDER BY total_revenue DESC;

-- Query 10: Upcoming appointments (three-table INNER JOIN)
SELECT a.appointment_id,
       CONCAT(p.first_name, ' ', p.last_name) AS patient,
       CONCAT('Dr. ', d.last_name) AS doctor,
       a.appt_date, a.reason
FROM appointment a
JOIN patient p ON a.patient_id = p.patient_id
JOIN doctor  d ON a.doctor_id  = d.doctor_id
WHERE a.status = 'Scheduled'
ORDER BY a.appt_date;

-- Query 11: Doctors with their departments
SELECT d.doctor_id,
       CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
       d.specialization, dep.dept_name, dep.location
FROM doctor d
INNER JOIN department dep ON d.dept_id = dep.dept_id
ORDER BY dep.dept_name, d.doctor_id;

-- Query 12: Patients who were never admitted (LEFT JOIN)
SELECT p.patient_id, p.first_name, p.last_name, p.city
FROM patient p
LEFT JOIN admission adm ON p.patient_id = adm.patient_id
WHERE adm.admission_id IS NULL
ORDER BY p.patient_id;

-- Query 13: Prescriptions written by cardiologists (four-table join)
SELECT CONCAT(p.first_name, ' ', p.last_name) AS patient,
       CONCAT('Dr. ', d.last_name) AS doctor,
       m.medicine_name, pr.dosage, pr.duration_days
FROM prescription pr
JOIN appointment a ON pr.appointment_id = a.appointment_id
JOIN patient p     ON a.patient_id = p.patient_id
JOIN doctor d      ON a.doctor_id = d.doctor_id
JOIN medicine m    ON pr.medicine_id = m.medicine_id
WHERE d.specialization = 'Cardiologist'
ORDER BY pr.prescription_id;

-- Query 14: Room charges of discharged patients
SELECT adm.admission_id, p.first_name, r.room_type,
       DATEDIFF(adm.discharge_date, adm.admit_date) AS stay_days,
       DATEDIFF(adm.discharge_date, adm.admit_date)
           * r.charge_per_day AS room_cost
FROM admission adm
JOIN patient p ON adm.patient_id = p.patient_id
JOIN room r    ON adm.room_id = r.room_id
WHERE adm.discharge_date IS NOT NULL
ORDER BY adm.admission_id;

-- Query 15: Doctors earning above the average (scalar subquery)
SELECT doctor_id, first_name, last_name, salary
FROM doctor
WHERE salary > (SELECT AVG(salary) FROM doctor)
ORDER BY salary DESC;

-- Query 16: Patients prescribed Aspirin (nested subquery)
SELECT patient_id, first_name, last_name
FROM patient
WHERE patient_id IN (
    SELECT patient_id FROM appointment
    WHERE appointment_id IN (
        SELECT appointment_id FROM prescription
        WHERE medicine_id = (SELECT medicine_id FROM medicine
                             WHERE medicine_name = 'Aspirin')))
ORDER BY patient_id;

-- Query 17: Patients with an unpaid bill (EXISTS)
SELECT p.patient_id, p.first_name, p.last_name
FROM patient p
WHERE EXISTS (SELECT 1 FROM bill b
              WHERE b.patient_id = p.patient_id
                AND b.payment_status <> 'Paid')
ORDER BY p.patient_id;

-- Query 18: View for pending payments
CREATE VIEW v_pending_bills AS
SELECT b.bill_id,
       CONCAT(p.first_name, ' ', p.last_name) AS patient,
       b.total_amount, b.payment_status
FROM bill b
JOIN patient p ON b.patient_id = p.patient_id
WHERE b.payment_status <> 'Paid';

SELECT * FROM v_pending_bills;

-- Query 19: Stock level report using CASE
SELECT medicine_name, stock_qty,
       CASE
           WHEN stock_qty < 100 THEN 'Reorder Now'
           WHEN stock_qty < 300 THEN 'Low'
           ELSE 'Sufficient'
       END AS stock_status
FROM medicine
ORDER BY stock_qty;

-- Query 20: Appointments handled by each department
SELECT dep.dept_name, COUNT(a.appointment_id) AS total_appointments
FROM department dep
LEFT JOIN doctor d       ON dep.dept_id = d.dept_id
LEFT JOIN appointment a  ON d.doctor_id = a.doctor_id
GROUP BY dep.dept_name
ORDER BY total_appointments DESC, dep.dept_name;


INSERT INTO department VALUES (1, 'Radiology', 'Block E', '0172-4001007');

INSERT INTO appointment VALUES (20, 99, 101, '2026-11-20', 'Checkup', 'Scheduled');

INSERT INTO doctor VALUES
(109, 'Test', 'Doctor', 'Dentist', '9876500109', -5000, 500, '2026-01-01', 1);

INSERT INTO patient (patient_id, first_name) VALUES (14, 'Test');


CREATE USER 'receptionist'@'localhost' IDENTIFIED BY 'Recep@123';
CREATE USER 'doctor_user'@'localhost' IDENTIFIED BY 'Doctor@123';

GRANT SELECT, INSERT, UPDATE ON medicare_db.patient
    TO 'receptionist'@'localhost';
GRANT SELECT, INSERT ON medicare_db.appointment
    TO 'receptionist'@'localhost';
GRANT SELECT ON medicare_db.* TO 'doctor_user'@'localhost';
GRANT INSERT, UPDATE ON medicare_db.prescription
    TO 'doctor_user'@'localhost';

REVOKE UPDATE ON medicare_db.patient FROM 'receptionist'@'localhost';
SHOW GRANTS FOR 'receptionist'@'localhost';

SELECT 'department' AS table_name, COUNT(*) AS total_rows FROM department
UNION ALL SELECT 'doctor', COUNT(*) FROM doctor
UNION ALL SELECT 'patient', COUNT(*) FROM patient
UNION ALL SELECT 'appointment', COUNT(*) FROM appointment
UNION ALL SELECT 'room', COUNT(*) FROM room
UNION ALL SELECT 'admission', COUNT(*) FROM admission
UNION ALL SELECT 'medicine', COUNT(*) FROM medicine
UNION ALL SELECT 'prescription', COUNT(*) FROM prescription
UNION ALL SELECT 'bill', COUNT(*) FROM bill;

USE medicare_db;

SHOW TABLES;

DESCRIBE patient;

SELECT d.doctor_id,
       CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
       d.specialization, dep.dept_name, dep.location
FROM doctor d
INNER JOIN department dep ON d.dept_id = dep.dept_id
ORDER BY dep.dept_name, d.doctor_id;

SELECT a.appointment_id,
       CONCAT(p.first_name, ' ', p.last_name) AS patient,
       CONCAT('Dr. ', d.last_name) AS doctor,
       a.appt_date, a.reason
FROM appointment a
JOIN patient p ON a.patient_id = p.patient_id
JOIN doctor  d ON a.doctor_id  = d.doctor_id
WHERE a.status = 'Scheduled'
ORDER BY a.appt_date;

SELECT CONCAT(p.first_name, ' ', p.last_name) AS patient,
       CONCAT('Dr. ', d.last_name) AS doctor,
       m.medicine_name, pr.dosage, pr.duration_days
FROM prescription pr
JOIN appointment a ON pr.appointment_id = a.appointment_id
JOIN patient p     ON a.patient_id = p.patient_id
JOIN doctor d      ON a.doctor_id = d.doctor_id
JOIN medicine m    ON pr.medicine_id = m.medicine_id
WHERE d.specialization = 'Cardiologist'
ORDER BY pr.prescription_id;

SELECT payment_mode,
       COUNT(*) AS bills,
       SUM(total_amount) AS total_revenue
FROM bill
WHERE payment_mode IS NOT NULL
GROUP BY payment_mode
ORDER BY total_revenue DESC;

SELECT patient_id, first_name, last_name
FROM patient
WHERE patient_id IN (
    SELECT patient_id FROM appointment
    WHERE appointment_id IN (
        SELECT appointment_id FROM prescription
        WHERE medicine_id = (SELECT medicine_id FROM medicine
                             WHERE medicine_name = 'Aspirin')))
ORDER BY patient_id;