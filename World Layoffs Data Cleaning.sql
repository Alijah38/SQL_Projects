-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


-- CREATED AN ALT TABLE TO DO CLEANING


SELECT *
FROM layoffs;

CREATE TABLE layoffs_alt
LIKE layoffs;

SELECT *
FROM layoffs_alt;

INSERT layoffs_alt
SELECT *
FROM layoffs;

-- REMOVED DUPLICATES

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_alt;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_alt
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_alt2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` bigint DEFAULT NULL,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_alt2;

INSERT INTO layoffs_alt2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_alt
;

SELECT *
FROM layoffs_alt2
WHERE row_num > 1;

DELETE
FROM layoffs_alt2
WHERE row_num > 1;


-- STANDARDIZING DATA

-- CHANGED DATE DATA TYPE FROM TEXT TO DATE 

SELECT `date`
FROM layoffs_alt2;

UPDATE layoffs_alt2
SET `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_alt2
MODIFY COLUMN `date` DATE;

-- TRIMMED THE COMPANY NAME TO REMOVE UNNECESSARY SPACES

SELECT company, TRIM(company)
FROM layoffs_alt2;

UPDATE layoffs_alt2
SET company = TRIM(company);

-- UPDATED SIMILAR INDUSTRY/COUNTRY COLUMN VALUES

SELECT *
FROM layoffs_alt2;

SELECT DISTINCT industry
FROM layoffs_alt2
ORDER BY 1;

SELECT *
FROM layoffs_alt2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_alt2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_alt2
ORDER BY 1;

SELECT *
FROM layoffs_alt2
WHERE country LIKE 'United States%'
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_alt2
ORDER BY 1;

UPDATE layoffs_alt2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- FIXED NULL VALUES & BLANKS

SELECT *
FROM layoffs_alt2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_alt2
WHERE industry IS NULL
OR industry = '';

UPDATE layoffs_alt2
SET industry = null
WHERE industry = '';

SELECT *
FROM layoffs_alt2
WHERE company = 'Carvana';

SELECT *
FROM layoffs_alt2 as alt1
JOIN layoffs_alt2 as alt2
	ON alt1.company = alt2.company
WHERE (alt1.industry IS NULL OR alt1.industry = '')
AND alt2.industry IS NOT NULL;

UPDATE layoffs_alt2 as alt1
JOIN layoffs_alt2 as alt2
	ON alt1.company = alt2.company
SET alt1.industry = alt2.industry
WHERE alt1.industry IS NULL
AND alt2.industry IS NOT NULL;

SELECT *
FROM layoffs_alt2
WHERE industry IS NULL
or industry = '';

-- REMOVED ANY UNNECESSARY COLUMNS AND ROWS 

SELECT *
FROM layoffs_alt2;

SELECT *
FROM layoffs_alt2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_alt2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT*
FROM layoffs_alt2;

ALTER TABLE layoffs_alt2
DROP COLUMN row_num;

SELECT*
FROM layoffs_alt2;


