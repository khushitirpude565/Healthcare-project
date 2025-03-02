CREATE SCHEMA IF NOT EXISTS healthcare;

-- Create ENUM type in the healthcare schema
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'insurance_status') THEN
        EXECUTE 'CREATE TYPE healthcare.insurance_status AS ENUM (''Yes'', ''No'')';
    END IF;
END $$;

-- Create the patient_data table
CREATE TABLE healthcare.patient_data (
    patient_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    age INT CHECK (age >= 0),  
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    contact VARCHAR(20),
    address TEXT NOT NULL,
    emergency_contact VARCHAR(20) NOT NULL,
    insurance healthcare.insurance_status NOT NULL,  -- ENUM now uses the schema
    insurance_provider VARCHAR(255), 
    insurance_number VARCHAR(50),
    allergies TEXT,
    current_medications TEXT,
    pre_existing_conditions TEXT,
    chief_complaint TEXT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE,
    final_diagnosis TEXT NOT NULL,
    treatment_cost DECIMAL(10,2),
    follow_up_appointment DATE,
    discharge_summary TEXT
);

ALTER TABLE healthcare.patient_data 
ALTER COLUMN treatment_cost SET DATA TYPE varchar(20);


ALTER TABLE healthcare.patient_data  
ALTER COLUMN contact set DATA TYPE varchar(200);

--to remove $
UPDATE healthcare.patient_data
SET treatment_cost = REPLACE(REPLACE(TRIM(treatment_cost), '$', ''), ',', '')::NUMERIC;

select * from  healthcare.patient_data 

-- to format names in correct format
SELECT INITCAP(full_name) AS formatted_name
FROM healthcare.patient_data

UPDATE healthcare.patient_data
SET full_name = INITCAP(full_name);

--to update allergies
UPDATE healthcare.patient_data
SET  allergies = INITCAP(allergies);

--giving dupicates for names only
SELECT full_name, COUNT(*) AS count
FROM healthcare.patient_data
GROUP BY LOWER(full_name),full_name
HAVING COUNT(*) > 1;

--complete info according to above query
SELECT *
FROM healthcare.patient_data
WHERE LOWER(full_name) IN (
    SELECT LOWER(full_name)
    FROM healthcare.patient_data
    GROUP BY LOWER(full_name)
    HAVING COUNT(*) > 1
)
ORDER BY full_name;

--shows that there are no excat duplicates
SELECT full_name, age, gender, contact, COUNT(*) AS duplicate_count
FROM healthcare.patient_data
GROUP BY full_name, age, gender, contact
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

--checking null
SELECT * 
FROM healthcare.patient_data
WHERE patient_id IS NULL OR full_name IS NULL OR age IS NULL;

-- age check
SELECT * FROM healthcare.patient_data
WHERE age < 0 OR age > 120;

--patient id check
SELECT patient_id, COUNT(*)
FROM healthcare.patient_data
GROUP BY patient_id
HAVING COUNT(*) > 1;

--dates check
SELECT * FROM  healthcare.patient_data
WHERE admission_date > discharge_date;

--null dates
SELECT admission_date, discharge_date 
FROM  healthcare.patient_data
WHERE EXTRACT(YEAR FROM admission_date) IS NULL 
   OR EXTRACT(YEAR FROM discharge_date) IS NULL;

--count of null dates
SELECT COUNT(*) 
FROM healthcare.patient_data
WHERE admission_date IS NULL OR discharge_date IS NULL;

SELECT current_user;


ALTER USER postgres WITH PASSWORD 'Khushi2201';
SHOW config_file;
