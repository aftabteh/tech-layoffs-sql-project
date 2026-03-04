-- ===========================================================
-- DATA CLEANING PROJECT: GLOBAL LAYOFFS
-- ===========================================================


-- ===========================================================
-- 1. CREATE STAGING TABLE
-- ===========================================================

CREATE TABLE layoffs_staging
LIKE layoffs; 

INSERT INTO layoffs_staging
SELECT * FROM layoffs;


-- ===========================================================
-- 2. REMOVE DUPLICATES
-- ===========================================================

-- Identify potential duplicates using ROW_NUMBER()

SELECT *, 
ROW_NUMBER() OVER( 
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num 
FROM layoffs_staging;

-- Use CTE to identify exact duplicates 

WITH duplicate_cte AS 
	(
	SELECT *, 
	ROW_NUMBER() OVER( 
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
	FROM layoffs_staging
	)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

-- Attempt deletion from CTE (not supported in MySQL)

WITH duplicate_cte AS 
(
SELECT *, 
ROW_NUMBER() OVER( 
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging
)
DELETE
FROM duplicate_cte 
WHERE row_num > 1;


-- Create second staging table including row_num column

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- Insert data with duplicate tracking column 

INSERT layoffs_staging2
SELECT *, 
	ROW_NUMBER() OVER( 
		PARTITION BY company, location, industry, total_laid_off, 
        percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num 
FROM layoffs_staging;

-- Review duplicate rows 

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

-- Delete duplicate rows 

DELETE 
FROM layoffs_staging2
WHERE row_num > 1; 

-- Confirm duplicates removed 

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2; 


-- ===========================================================
-- 3. STANDARDIZING DATA
-- ===========================================================

-- Trim extra spaces in company names 


SELECT company, (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company); 

SELECT * 
FROM layoffs_staging2; 

-- Review distinct industries 

SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY 1; 

-- Inspect crypto-related variations

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Standardize crypto industry labels

UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

-- Confirm standardization
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry 
FROM layoffs_staging2; 


-- Review distinct locations

SELECT DISTINCT location 
FROM layoffs_staging2
ORDER BY 1;


-- Review distinct countries 

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


-- Inspect inconsistent United States entries

SELECT DISTINCT country 
FROM layoffs_staging2
WHERE country LIKE 'United States%';


-- Standardize country name

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT DISTINCT country 
FROM layoffs_staging2
WHERE country LIKE 'United States%';

-- ===========================================================
-- DATE CONVERSION
-- ===========================================================

-- Review date column (currently TEXT)
SELECT `date`
FROM layoffs_staging2; 

-- Conver text to proper date format 

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change column datatype to DATE

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- ===========================================================
-- 4. HANDLE NULLS AND BLANK VALUES 
-- ===========================================================

-- Identify rows with no layoff information

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL; 
    
-- Review missing industry values

SELECT DISTINCT industry 
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Example inspection (Airbnb)
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Identify rows where industry can be populated via self-join

SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Convert blank industries to NULL

UPDATE layoffs_staging2 
SET industry = NULL
WHERE industry = ''; 

-- Populate missing industry values

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Review unresolved cases (example)

SELECT * 
FROM layoffs_staging2 
WHERE company LIKE 'Bally%';
-- so theres only one row we cant populate this 

SELECT * 
FROM layoffs_staging2; 


-- ===========================================================
-- 5. REMOVE UNNCECESSARY ROWS
-- ===========================================================

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Select statement for confirmation of deletion

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2; 


-- ===========================================================
-- 6. DROP HELPER COLUMN
-- ===========================================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num; 

SELECT *
FROM layoffs_staging2; 


-- ===========================================================
-- FINAL CLEAN DATASET
-- ===========================================================


