-- SQL Project - Data Cleaning

-- LINK TO DOWNLOAD EXCEL FILE: https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata



-- CREATED AN ALT TABLE TO DO CLEANING



SELECT *
FROM airbnb_open_data;

CREATE TABLE airbnb_open_data2
LIKE airbnb_open_data;

SELECT *
FROM airbnb_open_data2;

INSERT airbnb_open_data2
SELECT * 
FROM airbnb_open_data;

SELECT *
FROM airbnb_open_data2;

ALTER TABLE airbnb_open_data2
RENAME COLUMN `id` to ID, 
RENAME COLUMN NAME to name,
RENAME COLUMN `host id` to `host_id`,
RENAME COLUMN `host name` to `host_name`,
RENAME COLUMN `neighbourhood group` to `neighborhood_group`,
RENAME COLUMN `neighbourhood` to `neighborhood`,
RENAME COLUMN `room type` to `room_type`,
RENAME COLUMN `Construction year` to `construction_year`,
RENAME COLUMN `service fee` to `service_fee`,
RENAME COLUMN `minimum nights` to `minimum_nights`,
RENAME COLUMN `number of reviews` to `number_of_reviews`,
RENAME COLUMN `last review` to `last_review`,
RENAME COLUMN `reviews per month` to `reviews_per_month`,
RENAME COLUMN `review rate number` to `review_rate`,
RENAME COLUMN `calculated host listings count` to `host_listings_count`,
RENAME COLUMN `availability 365` to `days_available`
;



-- REMOVE DUPLICATES

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
name
) AS row_num
FROM airbnb_open_data2
;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
name
) AS row_num
FROM airbnb_open_data2
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- *DID NOT FIND ANY DUPLICATES



-- STANDARDIZING DATA


-- UPDATED BLANKS IN NEIGHBOURHOOD GROUP
 

SELECT *
FROM airbnb_open_data2 as alt1
JOIN airbnb_open_data2 as alt2
	ON alt1.neighborhood_group = alt2.neighborhood_group
WHERE alt1.neighborhood_group = ''
AND alt2.neighborhood IS NOT NULL;


UPDATE airbnb_open_data2 as alt1
JOIN airbnb_open_data2 as alt2
	ON alt1.neighborhood = alt2.neighborhood
SET alt1.neighborhood_group = alt2.neighborhood_group
WHERE alt1.neighborhood_group = ''
AND alt2.neighborhood IS NOT NULL;



-- UPDATED BLANKS IN COUNTRY


SELECT *
FROM airbnb_open_data2
WHERE country = ''
;

UPDATE airbnb_open_data2
SET country = 'United States'
WHERE country = '';

SELECT *
FROM airbnb_open_data2;



-- UPDATED COLUMNS WITH BLANKS TO NULL




UPDATE airbnb_open_data2
SET name = null
WHERE name = '';


UPDATE airbnb_open_data2
SET host_identity_verified = null
WHERE host_identity_verified = '';

UPDATE airbnb_open_data2
SET host_name = null
WHERE host_name = '';

UPDATE airbnb_open_data2
SET instant_bookable = null
WHERE instant_bookable = '';

UPDATE airbnb_open_data2
SET cancellation_policy = null
WHERE cancellation_policy = '';

UPDATE airbnb_open_data2
SET price = null
WHERE price = '';

UPDATE airbnb_open_data2
SET service_fee = null
WHERE service_fee = '';

UPDATE airbnb_open_data2
SET last_review = null
WHERE last_review = '';

UPDATE airbnb_open_data2
SET house_rules = null
WHERE house_rules = '';




-- CHANGED DATA TYPE FOR DATE, LAT, LONG COLUMNS



SELECT *
FROM airbnb_open_data2;

UPDATE airbnb_open_data2
SET last_review = str_to_date(`last_review`,'%m/%d/%Y');

ALTER TABLE airbnb_open_data2
MODIFY COLUMN `last_review` DATE;

ALTER TABLE airbnb_open_data2
MODIFY COLUMN lat DECIMAL(10, 5);

ALTER TABLE airbnb_open_data2
MODIFY COLUMN `long` DECIMAL(10, 5);


-- 	CALCULATED CORRECT VALUES FOR REVIEWS_PER_MONTH COLUMN


SELECT *
FROM airbnb_open_data2;

SELECT *
FROM airbnb_open_data2
WHERE reviews_per_month REGEXP '[^0-9]';

UPDATE airbnb_open_data2
SET reviews_per_month = NULL
WHERE reviews_per_month = '' REGEXP '[^0-9]';
    
    
SELECT 
    review_rate,
    number_of_reviews,
    last_review,
    reviews_per_month,
    number_of_reviews,
    TIMESTAMPDIFF(MONTH, last_review, CURDATE()) AS months_since_last_review,
    IF(TIMESTAMPDIFF(MONTH, last_review, CURDATE()) = 0, number_of_reviews, number_of_reviews / TIMESTAMPDIFF(MONTH, last_review, CURDATE())) AS reviews_per_month
FROM 
    airbnb_open_data2; 
    

UPDATE airbnb_open_data2
SET reviews_per_month = 
CAST(
    IF(
		TIMESTAMPDIFF(MONTH, last_review, CURDATE()) = 0,
		number_of_reviews,
		number_of_reviews / TIMESTAMPDIFF(MONTH, last_review, CURDATE())) AS DECIMAL(10,4)
);


-- UPDATED FIRST LETTER FOR TEXT COLUMNS


UPDATE airbnb_open_data2
SET name = REPLACE(CONCAT(UPPER(LEFT(name, 1)), 
LOWER(SUBSTRING(name, 2))),' , ', ', '), 
	host_identity_verified = REPLACE(CONCAT(UPPER(LEFT(host_identity_verified, 1)), 
LOWER(SUBSTRING(host_identity_verified, 2))),' , ', ', '), 
	neighborhood_group = REPLACE(CONCAT(UPPER(LEFT(neighborhood_group, 1)), 
LOWER(SUBSTRING(neighborhood_group, 2))),' , ', ', '),
	cancellation_policy = REPLACE(CONCAT(UPPER(LEFT(cancellation_policy, 1)), 
LOWER(SUBSTRING(cancellation_policy, 2))),' , ', ', '),
	instant_bookable = REPLACE(CONCAT(UPPER(LEFT(instant_bookable, 1)), 
LOWER(SUBSTRING(instant_bookable, 2))),' , ', ', ')
;


-- REMOVED ANY UNNECESSARY COLUMNS AND ROWS 


ALTER TABLE airbnb_open_data_alt
DROP COLUMN `country code`,
DROP COLUMN `license`
;


    
SELECT *
FROM airbnb_open_data2;


