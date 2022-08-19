SELECT *
FROM PortfolioProject..[covidDeaths]
ORDER BY location, date


SELECT *
FROM PortfolioProject..[covid-vaccinations]
ORDER BY location, date

-- 
-- Select Data that we are going to be using
--

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[covidDeaths]
--ORDER BY 1, 2
order by total_deaths


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if contract covid in your country
SELECT Location, date, total_cases, total_deaths, 
	(CAST (total_deaths AS float)/NULLIF(CAST(total_cases AS float), 0) ) * 100 AS DeathPercentage
FROM PortfolioProject..[covidDeaths]
WHERE location like '%united kingdom%'
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date, population, total_cases, 
	(CAST (total_cases AS float)/CAST(population AS float)) * 100 AS PercentagePopulation
FROM PortfolioProject..[covidDeaths]
WHERE location like '%united kingdom'
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX(CAST (total_cases AS float)/NULLIF(CAST(population AS float), 0) ) * 100 AS PercentPopulation
FROM PortfolioProject..[covidDeaths]
GROUP BY location, population
--ORDER BY 1, 2
ORDER BY PercentPopulation DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(Total_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent
SELECT location, MAX(CAST (Total_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
-- For some reason, IS NULL does not work here, something to do with varchar
WHERE continent like '0' 
  AND location not like '% income'
GROUP BY location
--GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST (Total_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
-- For some reason, IS NOT NULL does not work here, something to do with varchar
--WHERE continent NOT LIKE '0' 
WHERE continent in ('Asia', 'Africa', 'Europe', 'North America', 'South America')
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT	--date, 
		SUM(CAST (new_cases AS float)) AS total_cases,
		SUM(CAST (new_deaths AS float)) AS total_deaths, 
		( SUM(CAST (new_deaths AS float))/ NULLIF (SUM(CAST (new_cases AS float)), 0) ) * 100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent NOT LIKE '0'
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
SELECT *
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..[covid-vaccinations] vac
  ON	dea.location = vac.location
  AND	dea.date = vac.date


SELECT	dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, 
		SUM (CONVERT(float,vac.new_vaccinations)) 
			OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..[covid-vaccinations] vac
  ON	dea.location = vac.location
  AND	dea.date = vac.date
WHERE dea.continent NOT LIKE '0'
ORDER BY 1,2,3


-- USE CTE

WITH PopVsVac_CTE (Continent, Location, Date, Popuation, New_Vaccination, RollingPeopleVaccinated) 
AS
(
SELECT	dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, 
		SUM (CONVERT(float,vac.new_vaccinations)) 
			OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..[covid-vaccinations] vac
  ON	dea.location = vac.location AND	dea.date = vac.date
WHERE dea.continent IN ('Asia', 'Africa', 'Europe', 'North America', 'South America')
--ORDER BY 1,2,3
)

SELECT *, (RollingPeopleVaccinated / NULLIF(CAST(Popuation AS float),0))*100
FROM PopVsVac_CTE


-- TEMP TABLE

-- Make sure we are creating views and tables in our database - PortfolioPorject
USE PortfolioProject

DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT	dea.continent, dea.location, dea.date, dea.population, 
		CAST(vac.new_vaccinations as float), 
		SUM (CAST(vac.new_vaccinations as float)) 
			OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..[covid-vaccinations] vac
  ON	dea.location = vac.location AND	dea.date = vac.date
WHERE dea.continent IN ('Asia', 'Africa', 'Europe', 'North America', 'South America')

SELECT *, (RollingPeopleVaccinated/ NULLIF(CAST(Population AS float),0))*100 AS PopulationVaccinated
FROM PercentPopulationVaccinated


-- Creating View to store data for later visualizations
DROP VIEW IF EXISTS PopulationVaccinated

CREATE VIEW PopulationVaccinated
AS 
SELECT	dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, 
		SUM (CAST(vac.new_vaccinations as float)) 
			OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..[covid-vaccinations] vac
  ON	dea.location = vac.location AND	dea.date = vac.date
WHERE dea.continent IN ('Asia', 'Africa', 'Europe', 'North America', 'South America')
--ORDER BY 2, 3

SELECT *
FROM PopulationVaccinated
