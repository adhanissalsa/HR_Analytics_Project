-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;

-- The maximum number of total employee got laid off and maximum percentage of laid off from the company
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies that completely shutdown
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC; 

-- What company has the most laid off
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- When does the laid off period start and end?
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- What Industry got hit the most
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- What country had the most laid off
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Which year had the most laid off
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Which company stage had the most laid off
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Total laid off per month from the starting period
SELECT SUBSTRING(`date`,1, 7) AS `MONTH`, SUM(total_laid_off) AS SUM_TLO
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Cumulative sum of total laid off per month
WITH Rolling_Total AS
(SELECT SUBSTRING(`date`,1, 7) AS `MONTH`, SUM(total_laid_off) AS total_LO
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `month`, total_LO,
SUM(total_LO) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- How much each company laid off their employee per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- TOP 5 rank of company with the most laid off employees per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- -- TOP 5 rank of industry with the most laid off employees per year
WITH Industry_Year (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), Industry_Year_Rank AS
(SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE Ranking <= 5;