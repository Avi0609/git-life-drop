-- ===================================================================
-- LIFE DROP - PROFESSIONAL MYSQL DATABASE SCHEMA & SEED DATA
-- Primary Coverage: Jharkhand (Ranchi, Bokaro Sectors 1-12, Jamshedpur, Ramgarh, Deoghar, Hazaribagh)
-- Compatible with MySQL 5.7, 8.0+, MariaDB, and phpMyAdmin
-- ===================================================================

CREATE DATABASE IF NOT EXISTS blood_donation 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE blood_donation;

SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------------
-- 1. Table: blood_centers (Certified Blood Banks & Hospitals)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS blood_centers;
CREATE TABLE blood_centers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    locality VARCHAR(100) NOT NULL,
    state VARCHAR(100) DEFAULT 'Jharkhand',
    pincode VARCHAR(20) DEFAULT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(120) DEFAULT NULL,
    operating_hours VARCHAR(100) DEFAULT '24/7 Emergency Service',
    latitude DECIMAL(10, 6) DEFAULT NULL,
    longitude DECIMAL(10, 6) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_centers_city_loc (city, locality)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------------
-- 2. Table: blood_inventory (Component units per center)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS blood_inventory;
CREATE TABLE blood_inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    center_id INT NOT NULL,
    blood_group VARCHAR(10) NOT NULL,
    component VARCHAR(50) NOT NULL, -- 'Red cells', 'Platelets', 'Plasma', 'Whole blood'
    units_available INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_center FOREIGN KEY (center_id) REFERENCES blood_centers(id) ON DELETE CASCADE,
    UNIQUE KEY uk_center_group_comp (center_id, blood_group, component),
    INDEX idx_inventory_lookup (blood_group, component)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------------
-- 3. Table: donors (Registered Voluntary Lifesavers)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS donors;
CREATE TABLE donors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(120) DEFAULT NULL,
    blood_group VARCHAR(10) NOT NULL,
    city VARCHAR(100) NOT NULL,
    locality VARCHAR(100) NOT NULL,
    state VARCHAR(100) DEFAULT 'Jharkhand',
    pincode VARCHAR(20) DEFAULT NULL,
    address TEXT DEFAULT NULL,
    age INT DEFAULT NULL,
    gender VARCHAR(20) DEFAULT NULL,
    latitude DECIMAL(10, 6) DEFAULT NULL,
    longitude DECIMAL(10, 6) DEFAULT NULL,
    is_available TINYINT(1) DEFAULT 1,
    is_verified TINYINT(1) DEFAULT 1,
    suspicious_reports_count INT DEFAULT 0,
    last_donation_date DATE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_donors_search (city, locality, blood_group)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------------
-- 4. Table: blood_requests (Urgent Patient Transfusion Needs)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS blood_requests;
CREATE TABLE blood_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    blood_group VARCHAR(10) NOT NULL,
    component VARCHAR(50) NOT NULL,
    units_needed INT DEFAULT 1,
    hospital_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    locality VARCHAR(100) NOT NULL,
    state VARCHAR(100) DEFAULT 'Jharkhand',
    contact_name VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(30) NOT NULL,
    urgency VARCHAR(20) DEFAULT 'Normal', -- 'Critical', 'High', 'Normal'
    status VARCHAR(20) DEFAULT 'Open',    -- 'Open', 'Fulfilled', 'Cancelled'
    latitude DECIMAL(10, 6) DEFAULT NULL,
    longitude DECIMAL(10, 6) DEFAULT NULL,
    suspicious_reports_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_requests_city_blood (city, blood_group, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------------
-- 5. Table: suspicious_reports (Fraud & Broker Reporting System)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS suspicious_reports;
CREATE TABLE suspicious_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    target_type VARCHAR(20) NOT NULL, -- 'donor', 'request'
    target_id INT NOT NULL,
    reported_name VARCHAR(120) NOT NULL,
    reason VARCHAR(100) NOT NULL, -- 'Demanding Money / Commercial Seller', 'Fake Contact / Non-Responsive', 'Fake Hospital Request', 'Misbehavior / Harassment'
    details TEXT DEFAULT NULL,
    reporter_contact VARCHAR(50) DEFAULT NULL,
    status VARCHAR(30) DEFAULT 'Under Review', -- 'Under Review', 'Verified Fraud', 'Dismissed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------------
-- 6. Table: blood_camps (Donation Drives & Mobile Camps in Jharkhand)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS blood_camps;
CREATE TABLE blood_camps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    organizer VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    locality VARCHAR(100) NOT NULL,
    venue TEXT NOT NULL,
    camp_date DATE NOT NULL,
    start_time VARCHAR(20) DEFAULT '09:00 AM',
    end_time VARCHAR(20) DEFAULT '04:00 PM',
    contact_phone VARCHAR(30) NOT NULL,
    target_units INT DEFAULT 100,
    registered_donors_count INT DEFAULT 0,
    latitude DECIMAL(10, 6) DEFAULT NULL,
    longitude DECIMAL(10, 6) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_camps_city_date (city, camp_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ===================================================================
-- SEED DATA: JHARKHAND CERTIFIED BLOOD CENTERS
-- ===================================================================
INSERT INTO blood_centers (id, name, city, locality, state, pincode, address, phone, email, operating_hours, latitude, longitude) VALUES
-- RANCHI
(1, 'RIMS Blood Bank (Rajendra Institute of Medical Sciences)', 'Ranchi', 'Bariatu', 'Jharkhand', '834009', 'RIMS Hospital Campus, Bariatu Road, Ranchi', '+91 651 254 1533', 'rims.bloodbank@jharkhand.gov.in', '24/7 Emergency Service', 23.387600, 85.348600),
(2, 'Sadar Hospital Blood Centre', 'Ranchi', 'Lalpur', 'Jharkhand', '834001', 'Purulia Road, Near Lalpur Chowk, Ranchi', '+91 651 221 4455', 'sadar.ranchi@jharkhand.gov.in', '24/7 Emergency Service', 23.368500, 85.334000),
(3, 'Raj Hospital Blood Centre', 'Ranchi', 'Firayalal', 'Jharkhand', '834001', 'Main Road, Near Firayalal Chowk, Ranchi', '+91 651 233 0888', 'contact@rajhospitals.com', '24/7 Emergency Service', 23.364400, 85.324200),
(4, 'Guru Nanak Hospital Blood Bank', 'Ranchi', 'Station Road', 'Jharkhand', '834001', 'Station Road, Near Ranchi Railway Station, Ranchi', '+91 651 246 0999', 'gurunanak.blood@gmail.com', '8:00 AM - 10:00 PM', 23.351200, 85.328800),
(5, 'Nagarmal Modi Seva Sadan', 'Ranchi', 'Khatal', 'Jharkhand', '834001', 'Seva Sadan Road, Khatal / Upper Bazar, Ranchi', '+91 651 220 5678', 'sevasadan.ranchi@org.in', '24/7 Emergency Service', 23.371000, 85.318000),
(6, 'Morabadi Community Red Cross Centre', 'Ranchi', 'Morabadi', 'Jharkhand', '834008', 'Near Morabadi Ground & Tagore Hill Road, Ranchi', '+91 651 255 1212', 'morabadi.redcross@gmail.com', '24/7 Emergency Service', 23.395000, 85.332000),
(7, 'Kantatoli Trauma Blood Bank', 'Ranchi', 'Kantatoli', 'Jharkhand', '834001', 'Kantatoli Chowk, Circular Road, Ranchi', '+91 651 253 4400', 'kantatoli.blood@gmail.com', '24/7 Emergency Service', 23.369800, 85.345600),

-- BOKARO (Sectors 1 to 12 & Chas)
(8, 'Bokaro General Hospital (BGH) Blood Center', 'Bokaro', 'Sector 4', 'Jharkhand', '827004', 'BGH Campus, Main Hospital Road, Sector 4, Bokaro Steel City', '+91 6542 242 555', 'bgh.bloodbank@sail.in', '24/7 Emergency Service', 23.669300, 86.151100),
(9, 'Bokaro Steel Medical Center', 'Bokaro', 'Sector 1', 'Jharkhand', '827001', 'Sector 1 Market Road, Bokaro Steel City', '+91 6542 221 100', 'sector1.bcenter@sail.in', '24/7 Emergency Service', 23.679000, 86.138000),
(10, 'Sadar Hospital Blood Bank Bokaro', 'Bokaro', 'Chas', 'Jharkhand', '827013', 'ITI More, Chas, Bokaro', '+91 6542 265 890', 'sadar.chas@jharkhand.gov.in', '24/7 Emergency Service', 23.636000, 86.177000),
(11, 'KM Memorial Hospital Blood Center', 'Bokaro', 'Sector 12', 'Jharkhand', '827012', 'Sector 12 / Bypass Road, Chas-Bokaro', '+91 6542 233 444', 'kmmemorial@bokarohospital.com', '24/7 Emergency Service', 23.652000, 86.162000),

-- JAMSHEDPUR
(12, 'Tata Main Hospital (TMH) Blood Bank', 'Jamshedpur', 'Bistupur', 'Jharkhand', '831001', 'C Road, Bistupur, Jamshedpur', '+91 657 664 1000', 'tmh.bloodbank@tatasteel.com', '24/7 Emergency Service', 22.802800, 86.185400),
(13, 'MGM Medical College & Hospital Blood Bank', 'Jamshedpur', 'Sakchi', 'Jharkhand', '831001', 'Dimna Road, Sakchi, Jamshedpur', '+91 657 243 2124', 'mgm.blood@jharkhand.gov.in', '24/7 Emergency Service', 22.811500, 86.202900),
(14, 'Tata Motors Hospital Blood Bank', 'Jamshedpur', 'Telco', 'Jharkhand', '831010', 'Telco Colony, Jamshedpur', '+91 657 228 2345', 'tatamotors.blood@tatamotors.com', '24/7 Emergency Service', 22.776000, 86.251000),

-- RAMGARH
(15, 'Sadar Hospital Blood Bank Ramgarh', 'Ramgarh', 'Subhash Chowk', 'Jharkhand', '829122', 'Near Subhash Chowk, Ramgarh Cantt', '+91 6553 222 100', 'sadar.ramgarh@jharkhand.gov.in', '24/7 Emergency Service', 23.631000, 85.518000),
(16, 'Hope Hospital & Blood Center', 'Ramgarh', 'Gola Road', 'Jharkhand', '829122', 'Gola Road, Ramgarh Cantt', '+91 6553 224 555', 'hope.ramgarh@gmail.com', '24/7 Emergency Service', 23.628000, 85.524000),

-- DEOGHAR
(17, 'AIIMS Deoghar Blood Center', 'Deoghar', 'AIIMS Campus', 'Jharkhand', '814152', 'AIIMS Campus, Deviapur, Deoghar', '+91 6432 298 000', 'bloodbank@aiimsdeoghar.edu.in', '24/7 Emergency Service', 24.492000, 86.702000),
(18, 'Sadar Hospital Blood Bank Deoghar', 'Deoghar', 'Tower Chowk', 'Jharkhand', '814112', 'Castairs Town, Near Tower Chowk, Deoghar', '+91 6432 232 450', 'sadar.deoghar@jharkhand.gov.in', '24/7 Emergency Service', 24.485000, 86.697000),

-- HAZARIBAGH
(19, 'Sheikh Bhikhari Medical College & Hospital Blood Bank', 'Hazaribagh', 'Matwari', 'Jharkhand', '825301', 'Matwari Road, Sadar Campus, Hazaribagh', '+91 6546 264 300', 'sbmch.blood@jharkhand.gov.in', '24/7 Emergency Service', 23.996000, 85.362000),
(20, 'Arogyam Hospital Blood Bank', 'Hazaribagh', 'Korrah', 'Jharkhand', '825301', 'Korrah Road, Hazaribagh', '+91 6546 225 111', 'arogyam.blood@gmail.com', '24/7 Emergency Service', 23.988000, 85.372000);

-- ===================================================================
-- SEED DATA: BLOOD INVENTORY FOR JHARKHAND HOSPITALS
-- ===================================================================
INSERT INTO blood_inventory (center_id, blood_group, component, units_available) VALUES
-- 1. RIMS Ranchi (Bariatu)
(1, 'A+', 'Red cells', 35), (1, 'A+', 'Platelets', 18), (1, 'A+', 'Plasma', 22), (1, 'A+', 'Whole blood', 30),
(1, 'B+', 'Red cells', 42), (1, 'B+', 'Platelets', 24), (1, 'B+', 'Plasma', 28), (1, 'B+', 'Whole blood', 40),
(1, 'O+', 'Red cells', 50), (1, 'O+', 'Platelets', 30), (1, 'O+', 'Plasma', 35), (1, 'O+', 'Whole blood', 45),
(1, 'O-', 'Red cells', 14), (1, 'O-', 'Platelets', 6), (1, 'O-', 'Plasma', 8), (1, 'O-', 'Whole blood', 10),
(1, 'AB+', 'Red cells', 20), (1, 'AB+', 'Platelets', 12), (1, 'AB-', 'Red cells', 7),
-- 2. Sadar Hospital Ranchi (Lalpur)
(2, 'A+', 'Red cells', 22), (2, 'B+', 'Red cells', 28), (2, 'O+', 'Red cells', 35), (2, 'O-', 'Red cells', 6),
(2, 'AB+', 'Red cells', 14), (2, 'A-', 'Red cells', 5), (2, 'B-', 'Red cells', 4),
-- 3. Raj Hospital Ranchi (Firayalal)
(3, 'A+', 'Red cells', 18), (3, 'B+', 'Red cells', 22), (3, 'O+', 'Red cells', 26), (3, 'O-', 'Red cells', 4),
(3, 'AB+', 'Red cells', 10), (3, 'B+', 'Platelets', 14),
-- 5. Nagarmal Modi Seva Sadan (Khatal / Upper Bazar)
(5, 'A+', 'Whole blood', 15), (5, 'B+', 'Whole blood', 20), (5, 'O+', 'Whole blood', 25), (5, 'O-', 'Whole blood', 5),
-- 6. Morabadi Community Centre
(6, 'A+', 'Red cells', 12), (6, 'B+', 'Red cells', 16), (6, 'O+', 'Red cells', 20), (6, 'AB+', 'Red cells', 8),
-- 7. Kantatoli Trauma Centre
(7, 'O-', 'Red cells', 8), (7, 'O+', 'Red cells', 22), (7, 'B+', 'Red cells', 19), (7, 'A+', 'Red cells', 14),
-- 8. BGH Bokaro (Sector 4)
(8, 'A+', 'Red cells', 30), (8, 'A+', 'Platelets', 15), (8, 'B+', 'Red cells', 35), (8, 'B+', 'Platelets', 18),
(8, 'O+', 'Red cells', 45), (8, 'O+', 'Platelets', 20), (8, 'O-', 'Red cells', 10), (8, 'AB+', 'Red cells', 16),
-- 9. Bokaro Steel Medical (Sector 1)
(9, 'A+', 'Red cells', 14), (9, 'B+', 'Red cells', 18), (9, 'O+', 'Red cells', 22), (9, 'O-', 'Red cells', 4),
-- 10. Sadar Hospital Chas (Bokaro)
(10, 'A+', 'Red cells', 16), (10, 'B+', 'Red cells', 20), (10, 'O+', 'Red cells', 25), (10, 'AB+', 'Red cells', 9),
-- 12. TMH Jamshedpur (Bistupur)
(12, 'A+', 'Red cells', 32), (12, 'B+', 'Red cells', 38), (12, 'O+', 'Red cells', 48), (12, 'O-', 'Red cells', 12),
(12, 'AB+', 'Red cells', 18), (12, 'A-', 'Red cells', 8), (12, 'B-', 'Red cells', 6),
-- 15. Sadar Hospital Ramgarh
(15, 'A+', 'Red cells', 14), (15, 'B+', 'Red cells', 18), (15, 'O+', 'Red cells', 20), (15, 'O-', 'Red cells', 4),
-- 17. AIIMS Deoghar
(17, 'A+', 'Red cells', 25), (17, 'B+', 'Red cells', 30), (17, 'O+', 'Red cells', 35), (17, 'O-', 'Red cells', 9),
-- 19. Hazaribagh Medical College (Matwari)
(19, 'A+', 'Red cells', 20), (19, 'B+', 'Red cells', 25), (19, 'O+', 'Red cells', 30), (19, 'O-', 'Red cells', 6);

-- ===================================================================
-- SEED DATA: VERIFIED VOLUNTARY DONORS (Across specific sectors/localities)
-- ===================================================================
INSERT INTO donors (id, name, phone, email, blood_group, city, locality, state, address, age, gender, latitude, longitude, is_available, is_verified, suspicious_reports_count) VALUES
-- RANCHI DONORS
(1, 'Aman Verma', '+91 98351 12345', 'aman.verma@gmail.com', 'A+', 'Ranchi', 'Morabadi', 'Jharkhand', 'Near Morabadi Football Stadium, Ranchi', 26, 'Male', 23.392000, 85.334000, 1, 1, 0),
(2, 'Puja Kumari', '+91 98352 23456', 'puja.k@gmail.com', 'O+', 'Ranchi', 'Bariatu', 'Jharkhand', 'Near RIMS Doctors Colony, Bariatu, Ranchi', 24, 'Female', 23.385000, 85.352000, 1, 1, 0),
(3, 'Ravi Shankar Tiwari', '+91 98353 34567', 'ravi.tiwari@gmail.com', 'B+', 'Ranchi', 'Lalpur', 'Jharkhand', 'Peace Road, Lalpur Chowk, Ranchi', 29, 'Male', 23.371200, 85.336500, 1, 1, 0),
(4, 'Md. Imran Ansari', '+91 98354 45678', 'imran.ansari@gmail.com', 'O-', 'Ranchi', 'Kantatoli', 'Jharkhand', 'Near Kantatoli Flyover & Bus Stand, Ranchi', 31, 'Male', 23.368000, 85.348000, 1, 1, 0),
(5, 'Sunita Munda', '+91 98355 56789', 'sunita.munda@gmail.com', 'AB+', 'Ranchi', 'Firayalal', 'Jharkhand', 'Near Firayalal Chowk, Main Road, Ranchi', 27, 'Female', 23.363500, 85.326000, 1, 1, 0),
(6, 'Deepak Yadav', '+91 98356 67890', 'deepak.khatal@gmail.com', 'O+', 'Ranchi', 'Khatal', 'Jharkhand', 'Gwala Toli / Khatal Basti, Upper Bazar, Ranchi', 28, 'Male', 23.372500, 85.316000, 1, 1, 0),
(7, 'Neha Singh', '+91 98357 78901', 'neha.singh@gmail.com', 'A-', 'Ranchi', 'Doranda', 'Jharkhand', 'Hinoo-Doranda Main Road, Ranchi', 25, 'Female', 23.338000, 85.321000, 1, 1, 0),

-- BOKARO DONORS (Sectors 1 to 12 & Chas)
(8, 'Vikash Kumar Mahto', '+91 94311 11222', 'vikash.bgh@gmail.com', 'B+', 'Bokaro', 'Sector 4', 'Jharkhand', 'Sector 4/D, Bokaro Steel City', 32, 'Male', 23.665000, 86.154000, 1, 1, 0),
(9, 'Anjali Roy', '+91 94312 22333', 'anjali.roy@gmail.com', 'O+', 'Bokaro', 'Sector 1', 'Jharkhand', 'Sector 1/C, Bokaro Steel City', 23, 'Female', 23.681000, 86.141000, 1, 1, 0),
(10, 'Sanjay Soren', '+91 94313 33444', 'sanjay.soren@gmail.com', 'A+', 'Bokaro', 'Sector 6', 'Jharkhand', 'Sector 6/A, Bokaro Steel City', 34, 'Male', 23.674000, 86.126000, 1, 1, 0),
(11, 'Rajiv Lochan Sharma', '+91 94314 44555', 'rajiv.bokaro@gmail.com', 'O-', 'Bokaro', 'Sector 9', 'Jharkhand', 'Sector 9/B, Bokaro Steel City', 36, 'Male', 23.692000, 86.115000, 1, 1, 0),
(12, 'Pooja Pandey', '+91 94315 55666', 'pooja.pandey@gmail.com', 'AB+', 'Bokaro', 'Sector 12', 'Jharkhand', 'Sector 12/E, Bokaro Steel City', 28, 'Female', 23.649000, 86.168000, 1, 1, 0),
(13, 'Chandan Gorai', '+91 94316 66777', 'chandan.chas@gmail.com', 'B+', 'Bokaro', 'Chas', 'Jharkhand', 'Mahavir Chowk, Chas, Bokaro', 30, 'Male', 23.634000, 86.180000, 1, 1, 0),

-- JAMSHEDPUR DONORS
(14, 'Arjun Sen', '+91 94317 77888', 'arjun.sen@gmail.com', 'O+', 'Jamshedpur', 'Bistupur', 'Jharkhand', 'Main Road, Bistupur, Jamshedpur', 35, 'Male', 22.801000, 86.182000, 1, 1, 0),
(15, 'Suman Das', '+91 94318 88999', 'suman.das@gmail.com', 'A+', 'Jamshedpur', 'Sakchi', 'Jharkhand', 'Aambagan, Sakchi, Jamshedpur', 27, 'Female', 22.814000, 86.205000, 1, 1, 0),
(16, 'Harpreet Singh Gill', '+91 94319 99000', 'harpreet.telco@gmail.com', 'B-', 'Jamshedpur', 'Telco', 'Jharkhand', 'Plaza Market, Telco Colony, Jamshedpur', 33, 'Male', 22.778000, 86.253000, 1, 1, 0),

-- RAMGARH DONORS
(17, 'Manish Agarwal', '+91 93341 12121', 'manish.ramgarh@gmail.com', 'O+', 'Ramgarh', 'Ramgarh Cantt', 'Jharkhand', 'Near Subhash Chowk, Ramgarh Cantt', 29, 'Male', 23.630000, 85.520000, 1, 1, 0),

-- DEOGHAR DONORS
(18, 'Gaurav Kumar Jha', '+91 93342 23232', 'gaurav.deoghar@gmail.com', 'B+', 'Deoghar', 'Castairs Town', 'Jharkhand', 'Castairs Town, Near AIIMS Road, Deoghar', 31, 'Male', 24.488000, 86.699000, 1, 1, 0),

-- HAZARIBAGH DONORS
(19, 'Kunal Kishore', '+91 93343 34343', 'kunal.haz@gmail.com', 'A+', 'Hazaribagh', 'Matwari', 'Jharkhand', 'Matwari Chowk, Hazaribagh', 26, 'Male', 23.994000, 85.364000, 1, 1, 0);

-- ===================================================================
-- SEED DATA: LIVE BLOOD REQUESTS (Patients in Jharkhand Hospitals)
-- ===================================================================
INSERT INTO blood_requests (id, patient_name, blood_group, component, units_needed, hospital_name, city, locality, state, contact_name, contact_phone, urgency, status, latitude, longitude, suspicious_reports_count) VALUES
(1, 'Sita Ram Oraon', 'O-', 'Red cells', 2, 'RIMS Hospital, Emergency Ward', 'Ranchi', 'Bariatu', 'Jharkhand', 'Babulal Oraon (Brother)', '+91 98350 99881', 'Critical', 'Open', 23.387600, 85.348600, 0),
(2, 'Rameshwar Mahto', 'B+', 'Platelets', 4, 'Bokaro General Hospital (BGH), ICU', 'Bokaro', 'Sector 4', 'Jharkhand', 'Sunil Mahto (Son)', '+91 94310 88772', 'Critical', 'Open', 23.669300, 86.151100, 0),
(3, 'Priyanka Ghosh', 'A+', 'Whole blood', 2, 'Tata Main Hospital (TMH), Maternity', 'Jamshedpur', 'Bistupur', 'Jharkhand', 'Debashis Ghosh (Husband)', '+91 94310 77663', 'High', 'Open', 22.802800, 86.185400, 0),
(4, 'Md. Farhan', 'AB-', 'Red cells', 1, 'Sadar Hospital Blood Unit', 'Ranchi', 'Lalpur', 'Jharkhand', 'Zahid Hussain (Attendant)', '+91 98350 66554', 'High', 'Open', 23.368500, 85.334000, 0),
(5, 'Savitri Devi', 'O+', 'Whole blood', 2, 'Sadar Hospital, Trauma Ward', 'Ramgarh', 'Subhash Chowk', 'Jharkhand', 'Ajay Kumar (Son)', '+91 93340 55445', 'Normal', 'Open', 23.631000, 85.518000, 0),
(6, 'Rajesh Burnwal', 'O-', 'Whole blood', 3, 'AIIMS Hospital Deoghar', 'Deoghar', 'AIIMS Campus', 'Jharkhand', 'Manoj Burnwal (Brother)', '+91 93340 44336', 'Critical', 'Open', 24.492000, 86.702000, 0);

-- ===================================================================
-- SEED DATA: SUSPICIOUS ACTIVITY REPORTS (Sample verified protection data)
-- ===================================================================
INSERT INTO suspicious_reports (id, target_type, target_id, reported_name, reason, details, reporter_contact, status) VALUES
(1, 'donor', 999, 'Fake Broker Rajesh', 'Demanding Money / Commercial Seller', 'Caller demanded Rs 3,500 advance UPI payment for transportation charges before donating.', '+91 98350 11111', 'Verified Fraud'),
(2, 'request', 888, 'Suspicious Patient Alert', 'Fake Hospital Request', 'Contact person claimed patient at RIMS, but hospital admission records showed no such patient.', '+91 94310 22222', 'Under Review');

-- ===================================================================
-- SEED DATA: UPCOMING BLOOD CAMPS & MOBILE DRIVES IN JHARKHAND
-- ===================================================================
INSERT INTO blood_camps (id, title, organizer, city, locality, venue, camp_date, start_time, end_time, contact_phone, target_units, registered_donors_count, latitude, longitude) VALUES
(1, 'Mega Voluntary Blood Donation Camp - Morabadi', 'Jharkhand State AIDS Control Society & Red Cross', 'Ranchi', 'Morabadi', 'Morabadi Football Stadium Ground, Ranchi', '2026-10-28', '09:00 AM', '04:30 PM', '+91 98351 12345', 150, 48, 23.395000, 85.332000),
(2, 'Youth Lifesaver Mobile Blood Drive - Bokaro', 'SAIL Bokaro General Hospital & Rotary Club', 'Bokaro', 'Sector 4', 'Community Hall, Sector 4/C, Bokaro Steel City', '2026-10-30', '10:00 AM', '03:30 PM', '+91 6542 242 555', 100, 36, 23.669300, 86.151100),
(3, 'Steel City Corporate Blood Drive - Bistupur', 'Tata Main Hospital (TMH) Blood Centre', 'Jamshedpur', 'Bistupur', 'Tata Steel Ground & Community Center, Bistupur, Jamshedpur', '2026-11-02', '09:30 AM', '05:00 PM', '+91 657 664 1000', 200, 82, 22.802800, 86.185400),
(4, 'Coal Belt Lifeline Camp - Ramgarh', 'Sadar Hospital Ramgarh & Lions Club', 'Ramgarh', 'Subhash Chowk', 'Red Cross Bhawan, Near Subhash Chowk, Ramgarh Cantt', '2026-11-05', '09:00 AM', '03:00 PM', '+91 6553 222 100', 80, 24, 23.631000, 85.518000),
(5, 'AIIMS Sanjeevani Blood Camp - Deoghar', 'AIIMS Deoghar Blood Transfusion Dept', 'Deoghar', 'AIIMS Campus', 'OPD Block Courtyard, AIIMS Deviapur Campus, Deoghar', '2026-11-08', '09:00 AM', '04:00 PM', '+91 6432 298 000', 120, 52, 24.492000, 86.702000),
(6, 'Matwari Youth Blood Drive - Hazaribagh', 'Sheikh Bhikhari Medical College (SBMC)', 'Hazaribagh', 'Matwari', 'Town Hall Ground, Matwari, Hazaribagh', '2026-11-10', '10:00 AM', '04:00 PM', '+91 6546 264 300', 90, 29, 23.996000, 85.362000);


