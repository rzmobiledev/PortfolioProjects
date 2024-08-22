SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- lOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOW LIKELIKHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_deaths <> 0 AND Location LIKE '%indo%'
AND continent IS NOT NULL
ORDER BY 1,2 DESC

-- lOOKING AT TOTAL CASES VS POPULATION
-- SHOW WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE total_cases <> 0 AND Location LIKE '%indo%'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100
AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE total_cases <> 0
AND continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE total_deaths <> 0
AND continent IS NOT NULL
AND NOT location IN ('World', 'Asia', 'Africa', 'High-income countries', 'Lower-middle-income countries', 'Upper-middle-income countries', 'European Union (27)', 'Europe')
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Location IN ('World', 'Asia', 'Africa', 'High-income countries', 'Lower-middle-income countries', 'Upper-middle-income countries', 'European Union (27)', 'Europe', 'Oceania', 'International')
GROUP BY Location
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
(SUM(CAST(new_deaths AS int)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE new_cases <> 0
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
-- USE CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
SUM(CONVERT(BIGINT, vaccin.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
ON death.location = vaccin.location
AND death.date = vaccin.date
WHERE death.continent IS NOT NULL
AND death.location = 'Indonesia'
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopVsVac

-- CREATE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, CAST(death.population AS BIGINT) AS population, CAST(vaccin.new_vaccinations AS BIGINT) AS vaccinations,
SUM(CONVERT(BIGINT, vaccin.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
ON death.location = vaccin.location
AND death.date = vaccin.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, CAST(death.population AS BIGINT) AS population, CAST(vaccin.new_vaccinations AS BIGINT) AS vaccinations,
SUM(CONVERT(BIGINT, vaccin.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccin
ON death.location = vaccin.location
AND death.date = vaccin.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated