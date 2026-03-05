-- ==========================================================
-- PROJECT: Tech Layoffs Exploratory Data Analysis 
-- TOOL: MySQL
-- DATASET : Cleaned Tech Layoffs Dataset (2020-2023)
-- DESCRIPTION:
-- Exploratory analysis to identify trends across companies,
-- industries, countries, funding levels, and time periods. 
-- ===========================================================



-- ===========================================================
-- 1. Dataset Overview
-- ============================================================

-- Preview Cleaned Dataset 

SELECT *
FROM layoffs_staging2;

-- Maximum single-data layoffs, and maximum layoff percentage
-- Companies where 100% of employees were laid off
-- (percentage_laid_off = 1 represents 100%)

SELECT
	MAX(total_laid_off) AS max_total_laid_off,
    MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging2; 


-- 100% layoffs ordered by the total number of laid off

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;



-- 100% layoffs ordered by the highest funding raised

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- Britishvolt (Transporation industry) raised 2.4 billion in funds.

-- 100% layoffs ordered by most recent date 

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY `date` DESC;
-- latest lay off according to dataset 2023-03-02.


-- ===========================================================
-- 2. Company-Level Analysis
-- ============================================================

-- Total layoffs by company

SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC;
-- Amazon resulted in the highest lay offs company-wise with a total of 18150. 


-- Layoffs by company per year (ordered by highest totals)
SELECT company, YEAR(`date`) AS `YEAR`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, `YEAR`
ORDER BY 3 DESC;
-- Google laid off the highest in 2023, where total_laid_off = 12000


-- ===========================================================
-- 3. Industry and Country Analysis
-- ============================================================

-- Total layoffs by industry 
SELECT 
	industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry 
ORDER BY total_laid_off DESC;
-- The consumer industry had the highest layoffs, where total_laid_off = 45182

-- Total layoffs by country 
SELECT 
	country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;
-- The United States had the highest layoffs, where total_laid_off = 256559

-- Total layoffs by company stage 
SELECT 
	stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;
-- POST-IPO had the highest lay offs, where total_laid_off = 204132

-- ===========================================================
-- 4. Time-Based Analysis
-- ============================================================

-- DATE range of dataset
SELECT 
	MIN(`date`) AS start_date, MAX(`date`) AS end_date
FROM layoffs_staging2; 

-- Yearly layoffs

SELECT YEAR(`date`) AS `YEAR`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY `YEAR`
ORDER BY `YEAR` DESC;


-- Monthly layoffs
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH` , 
	   SUM(total_laid_off) AS total_laid_off 
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Rolling Monthly total of layoffs
WITH Rolling_Total AS
(
	SELECT 
		SUBSTRING(`date`, 1, 7) AS `MONTH`, 
	    SUM(total_laid_off) AS monthly_sum
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1 ASC
)
SELECT 
	`MONTH`, 
    monthly_sum, 
	SUM(monthly_sum) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;


-- ===========================================================
-- 5. Ranking Analysis
-- Top 5 Companies by Layoffs Per Year
-- ============================================================

WITH Company_Year (company, years, total_laid_off) AS 
(
    SELECT 
        company, 
        YEAR(`date`), 
        SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
    ORDER BY 3 DESC
), 
Company_Year_Rank AS 
(
    SELECT *, 
        DENSE_RANK() OVER 
        (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;


