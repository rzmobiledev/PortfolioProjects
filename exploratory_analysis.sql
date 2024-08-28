/*
DATA ANALYSIS
*/
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs.layoff_staging2;

SELECT *
FROM world_layoffs.layoff_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoff_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs.layoff_staging2;

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoff_staging2
GROUP BY country;

SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoff_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT company, AVG(percentage_laid_off)
FROM world_layoffs.layoff_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT SUBSTRING(`date`, 1,7) AS MONTH, SUM(total_laid_off) 
FROM world_layoffs.layoff_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1 ASC;

/*---------------- 
take year and month, 
sum total_laid_off
*/
SELECT *
FROM world_layoffs.layoff_staging2
ORDER BY date;

WITH Rolling_Total AS
(
	SELECT SUBSTRING(date, 1, 7) AS MONTH,
	SUM(total_laid_off) AS total_off
	FROM world_layoffs.layoff_staging2
	WHERE SUBSTRING(date, 1, 7)
	GROUP BY MONTH
	ORDER BY 1
)
SELECT MONTH, total_off,
SUM(total_off) OVER(ORDER BY MONTH) AS rolling_total
FROM Rolling_Total
;

SELECT company, YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoff_staging2
GROUP BY company, YEAR(date)
ORDER BY 3 DESC;

WITH Company_Year (Company, Years, Total_laid_off) AS
(
	SELECT company, YEAR(date), SUM(total_laid_off)
	FROM world_layoffs.layoff_staging2
	GROUP BY company, YEAR(date)
	ORDER BY 3 DESC
),
Laid_off_company AS
(
	SELECT *, 
	DENSE_RANK() OVER(PARTITION BY Years ORDER BY Total_laid_off DESC) AS ranking
	FROM Company_Year
	WHERE Years IS NOT NULL
)

SELECT *
FROM Laid_off_company
WHERE ranking <=5
;

/*
EXERCISE
*/
SELECT *
FROM world_layoffs.layoff_staging2;

WITH company_laid_off(company, years, total_laid_off) AS
(
	SELECT company, YEAR(date), SUM(total_laid_off)
	FROM world_layoffs.layoff_staging2
	GROUP BY company, YEAR(date)
	ORDER BY 3 DESC
),
company_rank_laid_off AS
(
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
	FROM company_laid_off
	WHERE years IS NOT NULL
)
    
SELECT *
FROM company_rank_laid_off
WHERE ranking <=5

