/*
DATA CLEANING
*/

SELECT *
FROM world_layoffs.layoffs;

CREATE TABLE world_layoffs.layoff_staging
LIKE world_layoffs.layoffs;

SELECT *
FROM world_layoffs.layoff_staging;

INSERT world_layoffs.layoff_staging
SELECT * FROM world_layoffs.layoffs;

-- REMOVE DUPLICATE

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM world_layoffs.layoff_staging;

WITH duplicate_cte AS (
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
        stage, country, funds_raised_millions
	) AS row_num
	FROM world_layoffs.layoff_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1
;

WITH duplicate_cte AS (
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
        stage, country, funds_raised_millions
	) AS row_num
	FROM world_layoffs.layoff_staging
)
DELETE FROM duplicate_cte
WHERE row_num > 1
;

CREATE TABLE `layoff_staging2` (
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


SELECT *
FROM world_layoffs.layoff_staging2
WHERE row_num > 1;

INSERT INTO world_layoffs.layoff_staging2
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
        stage, country, funds_raised_millions
	) AS row_num
	FROM world_layoffs.layoff_staging;


DELETE
FROM world_layoffs.layoff_staging2
WHERE row_num > 1;

SELECT *
FROM world_layoffs.layoff_staging2;

-- STANDARDIZE THE DATA
SELECT company, TRIM(company)
FROM world_layoffs.layoff_staging2;

UPDATE world_layoffs.layoff_staging2
SET company = TRIM(company);

SELECT *
FROM world_layoffs.layoff_staging2
WHERE industry LIKE 'Crypto%';

UPDATE world_layoffs.layoff_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)

ORDER BY 1;

UPDATE world_layoffs.layoff_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM world_layoffs.layoff_staging2
ORDER BY 1 DESC;

-- CHANGE DATE TEXT TO DATE
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs.layoff_staging2;

UPDATE world_layoffs.layoff_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT *
FROM world_layoffs.layoff_staging2;

-- THEN CHANGE DATE COLUMN TO DATE FORMAT
ALTER TABLE world_layoffs.layoff_staging2
MODIFY COLUMN `date` DATE;

-- NULL VALUES OR BLANK VALUES
SELECT *
FROM world_layoffs.layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoff_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM world_layoffs.layoff_staging2
WHERE company = 'Airbnb';

SELECT *
FROM world_layoffs.layoff_staging2
WHERE company LIKE 'Bally%';

SELECT t1.company, t1.industry , t2.company, t2.industry 
FROM world_layoffs.layoff_staging2 t1
JOIN world_layoffs.layoff_staging2 t2
ON
	t1.company = t2.company
WHERE (t1.industry IS NULL AND t1.industry = '')
AND t2.industry IS NOT NULL
ORDER BY 1
    ;

UPDATE world_layoffs.layoff_staging2 t1
JOIN world_layoffs.layoff_staging2 t2    
ON
	t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;

-- UPDATE ABOVE IS FAILED. LETS TRY ANOTHER ONE
UPDATE world_layoffs.layoff_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM world_layoffs.layoff_staging2;

-- REMOVE ANY COLUMNS

SELECT *
FROM world_layoffs.layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM world_layoffs.layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE
world_layoffs.layoff_staging2
DROP COLUMN row_num;

