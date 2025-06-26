-- SQL PROJECT DATA CLEANING

-- EXCEL FILE IN GITHUB REPOSITORY


-- CREATED AN ALT TABLE TO DO CLEANING


SELECT *
FROM patient_visits;

CREATE TABLE patient_visits2
LIKE patient_visits;

SELECT *
FROM patient_visits2;

INSERT patient_visits2
SELECT *
FROM patient_visits;

ALTER TABLE patient_visits2
RENAME COLUMN `Charges ($)` to `Charges`,
RENAME COLUMN `Insurance Provider` to `Insurance_Provider`;

-- REMOVE DUPLICATES

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
Patient_ID
) AS row_num
FROM patient_visits2
;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
Patient_ID
) AS row_num
FROM patient_visits2
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- *DID NOT FIND ANY DUPLICATES

-- STANDARDIZING DATA

-- CONVERTED DATE COLUMN

SELECT *
FROM patient_visits2;

SELECT DISTINCT Date_of_Visit
FROM patient_visits2;

ALTER TABLE patient_visits2 
ADD COLUMN converted_date DATE;

UPDATE patient_visits2 SET converted_date = CASE
    WHEN Date_of_Visit REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        THEN STR_TO_DATE(Date_of_Visit, '%m-%d-%Y')
        
    WHEN Date_of_Visit REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
        THEN STR_TO_DATE(Date_of_Visit, '%Y/%m/%d')
        
    WHEN Date_of_Visit REGEXP '^[A-Za-z]{3} [0-9]{1,2}, [0-9]{4}$'
        THEN STR_TO_DATE(Date_of_Visit, '%b %d, %Y')
        
	WHEN Date_of_Visit REGEXP '^[0-9]{4}\\.[0-9]{2}\\.[0-9]{2}$'
        THEN STR_TO_DATE(Date_of_Visit, '%Y.%m.%d')
    ELSE NULL
END;

ALTER TABLE patient_visits2
DROP COLUMN Date_of_Visit; 

ALTER TABLE patient_visits2
RENAME COLUMN `converted_date` to `Date_of_Visit`;

-- UPDATED BLANKS TO NULL

SELECT *
FROM patient_visits2;

UPDATE patient_visits2
SET Age = null
WHERE Age = '';

UPDATE patient_visits2
SET DIAGNOSIS_CODE = null
WHERE DIAGNOSIS_CODE = '';

UPDATE patient_visits2
SET BLOOD_PRESSURE = null
WHERE BLOOD_PRESSURE = '';

UPDATE patient_visits2
SET HEART_RATE = null
WHERE HEART_RATE = '';

UPDATE patient_visits2
SET DOCTOR = null
WHERE DOCTOR = '';

UPDATE patient_visits2
SET CHARGES = null
WHERE CHARGES = '';

UPDATE patient_visits2
SET INSURANCE_PROVIDER = null
WHERE INSURANCE_PROVIDER = '';

UPDATE patient_visits2
SET NOTES = 'Unknown'
	WHERE notes is null
	or notes =  ''
    or notes = '-'
    or notes = 'n/a';
    
UPDATE patient_visits2
SET NOTES = null
WHERE NOTES = 'Unknown'; 

-- STANDARDIZED SPELLING OF SIMILAR DATA ENTRIES

UPDATE patient_visits2
SET Gender = 'Female'
	WHERE Gender = 'female'
	or Gender =  'F';  
    
UPDATE patient_visits2
SET Gender = 'Male'
	WHERE Gender = 'male'
	or Gender =  'M';  
    
UPDATE patient_visits2
SET Insurance_Provider = 'UnitedHealthCare'
	WHERE Insurance_Provider = 'united health';
    
UPDATE patient_visits2
SET Insurance_Provider = 'BlueCross'
	WHERE Insurance_Provider = 'Blue cross';
    
UPDATE patient_visits2
SET Insurance_Provider = 'Aetna'
	WHERE Insurance_Provider = 'AETNA';
    
-- REMOVING '$' FROM CHARGES COLUMN

SELECT CHARGES 
FROM patient_visits2
WHERE Charges LIKE '%$%';

UPDATE patient_visits2
SET CHARGES = REPLACE(CHARGES, '$', '')
WHERE CHARGES LIKE '%$%';

-- NORMALIZED BLOOD PRESSURE COLUMN

SELECT *
FROM patient_visits2;

UPDATE patient_visits2
SET Blood_Pressure = REPLACE(Blood_Pressure, ' ', '')
WHERE Blood_Pressure LIKE '% %';

SELECT *
FROM patient_visits2;





