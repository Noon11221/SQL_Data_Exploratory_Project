SELECT * FROM layoffs_staging2
LIMIT 100

--
ALTER TABLE layoffs_staging2
ALTER COLUMN total_laid_off TYPE INTEGER
USING total_laid_off::INTEGER; 
--
ALTER TABLE layoffs_staging2
ALTER COLUMN percentage_laid_off TYPE NUMERIC
USING percentage_laid_off::NUMERIC; 

-- Date range
SELECT MIN(date), MAX(date)
FROM layoffs_staging2

-- Total layoffs by company analysis
SELECT
    company,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2 
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY total_laid_off DESC

-- Total layoffs by country analysis
SELECT 
    country,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY total_laid_off DESC


-- Total layoffs by year analysis
SELECT
    EXTRACT (YEAR FROM date) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY year
ORDER BY year DESC;

-- Total layoffs by stage analysis
SELECT 
    stage,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY stage
ORDER BY total_laid_off DESC

-- Total layoffs by month analysis
SELECT EXTRACT (MONTH FROM date) AS month,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY month
ORDER BY month;

-- Total layoffs by month-year
SELECT DATE_TRUNC('MONTH', date)::DATE AS month,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE DATE_TRUNC('MONTH', date) IS NOT NULL
GROUP BY month
ORDER BY month

-- Cumulative layoffs over time
WITH t AS (
    SELECT DATE_TRUNC('MONTH', date)::DATE AS month,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE DATE_TRUNC('MONTH', date) IS NOT NULL
GROUP BY month
ORDER BY month
)
SELECT
    month,
    total_laid_off,
    SUM(total_laid_off) OVER (ORDER BY month) AS cumulative_laid_off
FROM t

-- Cumulative layoffs by year
WITH running_total AS (
    SELECT DATE_TRUNC('MONTH', date)::DATE AS month,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE DATE_TRUNC('MONTH', date) IS NOT NULL
GROUP BY month
)
SELECT
    month,
    total_laid_off,
    SUM(total_laid_off) OVER(PARTITION BY EXTRACT(YEAR FROM month) ORDER BY month) AS cumulative_laid_off
FROM running_total
ORDER BY month;

-- Yearly layoffs by company
SELECT
    company,
    EXTRACT(YEAR FROM date) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2 
WHERE total_laid_off IS NOT NULL
GROUP BY company, EXTRACT(YEAR FROM date)
ORDER BY year,total_laid_off DESC; 


-- Top 5 companies with most layoffs by year
WITH ranked_layoffs AS (
    SELECT
        company,
        EXTRACT(YEAR FROM date) AS year,
        SUM(total_laid_off) AS total_laid_off,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM date) ORDER BY SUM(total_laid_off) DESC) AS rank
    FROM layoffs_staging2
    WHERE total_laid_off IS NOT NULL
    GROUP BY company, EXTRACT(YEAR FROM date)
)
SELECT
    year,
    company,
    total_laid_off,
    rank
FROM ranked_layoffs
WHERE rank <= 5
ORDER BY year DESC, total_laid_off DESC;



--- Total layoffs by year
SELECT 
    EXTRACT(YEAR FROM date) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY year
ORDER BY total_laid_off DESC;


