# Exploratory Data Analysis – Tech Layoffs Dataset

## Introduction
This project focuses on **exploratory data analysis (EDA)** of a cleaned tech layoffs dataset.  
The objective is to uncover patterns, trends, and insights related to layoffs across companies, countries, industries, and time.

All analysis is performed using **SQL in PostgreSQL**, leveraging aggregation functions, date functions, and window functions to analyze the data from multiple perspectives.

Check SQL queries out here: [data_exploratoty folder](/data_exploratory/coding.sql)

---

## Background
After completing the data cleaning phase, the dataset is now reliable and consistent for analysis.  
The cleaned dataset includes information such as:
- Company name
- Country
- Industry
- Company stage
- Total number of employees laid off
- Layoff dates

This EDA project aims to answer key questions such as:
- Which companies had the most layoffs?
- Which countries were most affected?
- How did layoffs evolve over time?
- Which years and months saw the highest layoffs?
- How layoffs accumulated over time

---

## Tools I Used
- **PostgreSQL** – exploratory data analysis
- **SQL** – aggregation, window functions, date functions
- **VS Code** – query writing and execution
- **Git & GitHub** – version control and project documentation

---

## The Analysis

### 1. Date Range Analysis
- Identified the earliest and latest layoff dates in the dataset.
- Established the time span covered by the data.
```sql
SELECT MIN(date), MAX(date)
FROM layoffs_staging2
```
### 2. Total Layoffs by Company
- Aggregated total layoffs per company.
- Ranked companies by total number of employees laid off.
- Identified companies most impacted by layoffs.
```sql
SELECT
    company,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2 
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY total_laid_off DESC
```

### 3. Total Layoffs by Country
- Summarized layoffs by country.
- Compared the impact of layoffs across different regions.
```sql
SELECT 
    country,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY total_laid_off DESC
```

### 4. Total Layoffs by Year
- Extracted year from layoff dates.
- Analyzed yearly trends to identify peak layoff periods.
```sql
SELECT
    EXTRACT (YEAR FROM date) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY year
ORDER BY year DESC;
```

### 5. Total Layoffs by Company Stage
- Grouped layoffs by company stage (e.g. startup, post-IPO).
- Identified which stages experienced the highest layoffs.
```sql
SELECT 
    stage,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY stage
ORDER BY total_laid_off DESC
```

### 6. Monthly Layoff Trends
- Analyzed layoffs by month to observe seasonal patterns.
- Extended analysis to month–year combinations for more precise trend tracking.
```sql
SELECT DATE_TRUNC('MONTH', date)::DATE AS month,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE DATE_TRUNC('MONTH', date) IS NOT NULL
GROUP BY month
ORDER BY month
```

### 7. Cumulative Layoffs Over Time
- Calculated running totals of layoffs by month.
- Visualized how layoffs accumulated over time across the entire dataset.
```sql
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
```

### 8. Cumulative Layoffs by Year
- Calculated cumulative layoffs within each year.
- Compared layoff progression year over year.
```sql
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

```
### 9. Yearly Layoffs by Company
- Analyzed company-level layoffs on a yearly basis.
- Observed how individual companies’ layoff patterns changed over time.
```sql
SELECT
    company,
    EXTRACT(YEAR FROM date) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2 
WHERE total_laid_off IS NOT NULL
GROUP BY company, EXTRACT(YEAR FROM date)
ORDER BY year,total_laid_off DESC; 
```

### 10. Top 5 Companies by Layoffs Each Year
- Ranked companies by total layoffs within each year.
- Identified the top 5 companies with the most layoffs annually.
```sql
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
```
---

## What I Learned
- How to use SQL for exploratory data analysis instead of relying solely on visualization tools
- Applying aggregation functions (`SUM`, `GROUP BY`) to answer business questions
- Using date functions such as `EXTRACT` and `DATE_TRUNC`
- Implementing window functions for cumulative and ranking analysis
- Structuring EDA queries to progressively build insights

---

## Conclusions
From this exploratory analysis:
- Layoffs are concentrated among certain companies and countries
- Specific years experienced significantly higher layoffs
- Layoffs tend to accumulate rapidly during economic downturn periods
- A small number of companies often account for a large share of total layoffs

This EDA provides a strong foundation for:
- Data visualization
- Dashboard creation
- Deeper business and economic analysis


