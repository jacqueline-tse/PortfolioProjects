

-- 1.

SELECT	SUM(CAST (new_cases AS float)) AS total_cases,
		SUM(CAST (new_deaths AS float)) AS total_deaths, 
		( SUM(CAST (new_deaths AS float))/ NULLIF (SUM(CAST (new_cases AS float)), 0) ) * 100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent NOT LIKE '0'
ORDER BY 1,2


-- 2.

-- We take these out as they are not included in the above query and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST (new_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent LIKE '0' 
  AND location NOT IN ('World', 'European Union', 'International')
  AND location NOT LIKE '% income'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX(CAST (total_cases AS float)/NULLIF(CAST(population AS float), 0) )*100 AS PercentPopulationInfected
FROM PortfolioProject..[covidDeaths]
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4. 

-- For each day, find the infection count and the percentage of population infected

SELECT Location, population, date, MAX(total_cases) AS HighestInfectionCount, 
	MAX(CAST (total_cases AS float)/NULLIF(CAST(population AS float), 0) )*100 AS PercentPopulationInfected
FROM PortfolioProject..[covidDeaths]
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC


-- 5. 

-- Find the top 10 highest populated countries

SELECT TOP 10 Location, MAX(CAST (population AS FLOAT)) AS MaxPopulation
FROM PortfolioProject..[covidDeaths]
WHERE location NOT IN ('World', 'Asia', 'Africa', 'Europe', 'European Union', 'North America', 'South America')
  AND location NOT LIKE '% income'
GROUP BY location, population
--ORDER BY PercentPopulationInfected DESC
ORDER BY MaxPopulation DESC
