-- DATA CLEANING

SELECT *
FROM worlds_layoff.layoffs;

-- CREATE STAGING TABLE

CREATE TABLE worlds_layoff.layoffs_staging
LIKE worlds_layoff.layoffs;

INSERT layoffs_staging
SELECT *
FROM worlds_layoff.layoffs;

-- 1. CHECK & REMOVE DUPLICATES

SELECT *
FROM worlds_layoff.layoffs_staging;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Duplicates checkpoint
SELECT *
FROM layoffs_staging
WHERE company = 'Beyond Meat';

-- Create staging table for deleting duplicates
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage,
country, funds_raised) AS row_num
FROM layoffs_staging;

-- Filtering duplicates
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Deleting duplicates
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. STANDARDIZING DATA

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Issues checkpoint: Industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Standardizing Industry for eBay
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'eBay';

UPDATE layoffs_staging2
SET industry = 'Retail'
WHERE company LIKE 'eBay';

-- Issues checkpoint: Location
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE location LIKE 'Malmo';

UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE location LIKE 'MalmÃ¶%';

-- Issues checkpoint: Country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country = 'Sweden'
ORDER BY location;

-- Standardizing date column type
SELECT `date`,
STR_TO_DATE(`date`, '%Y-%m-%d')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `DATE` = STR_TO_DATE(`date`, '%Y-%m-%d');

-- Change column type to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

ALTER TABLE layoffs_staging2
MODIFY COLUMN funds_raised INT;

-- 3. CHECK NULLs AND BLANKs
-- Checking null column data
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Blanks checkpoint
SELECT *
FROM layoffs_staging2
WHERE funds_raised IS NULL
OR funds_raised = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Appsmith';

-- Populate blank/null industry with the existing one of the same company and location
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2  t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
	AND t2.industry IS NOT NULL;

-- Changing blank data into NULLs
UPDATE layoffs_staging2
SET funds_raised = NULL
WHERE funds_raised = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2  t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

-- 4. CHECK NULL VALUES THAT CAN BE UNNECESSARY
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- Drop unnecessary column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
