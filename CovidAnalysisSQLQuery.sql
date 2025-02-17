SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths';

--Exploring whole data and ordering by location and date
SELECT * 
FROM covid_analysis_project..CovidDeaths
ORDER BY 3,4;

--Checking out death rate caused by covid
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_rate
FROM covid_analysis_project..CovidDeaths
ORDER BY 1,2;

--Checking out death rate caused by covid in Turkey
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_rate
FROM covid_analysis_project..CovidDeaths
WHERE location = 'Turkey'
ORDER BY 1,2;
 
--Checking total death rate by country
SELECT location, (SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100) AS TotalDeathRate
FROM covid_analysis_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathRate DESC;




--What percent of the population is infected through days?
SELECT location, date, total_cases, population, (COALESCE(total_cases, 0) / NULLIF(population, 0)) * 100 AS infection_rate
FROM covid_analysis_project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--IN total what percent of population is infected
SELECT location, population, MAX(total_cases) AS HighestInfectionNumber, MAX((total_cases / population)) *100 AS HighestInfectionRate
FROM covid_analysis_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionRate DESC;

--Highest death count by country
SELECT location, MAX(total_deaths) AS OverallDeath
FROM covid_analysis_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY OverallDeath DESC;


--Highest death count by continent
SELECT location, MAX(total_deaths) AS OverallDeath
FROM covid_analysis_project..CovidDeaths
WHERE continent IS NULL 
AND location NOT IN('World', 'European Union', 'International')
GROUP BY location
ORDER BY OverallDeath DESC;


--CasesbyDay and DeathbyDay
SELECT date, SUM(new_cases) AS CasesbyDay, SUM(new_deaths) AS DeathbyDay
FROM covid_analysis_project..CovidDeaths
GROUP BY date
ORDER BY 1;


--Exploring Vaccination data

SELECT *
FROM covid_analysis_project..CovidVaccinations
ORDER BY date

--When does the first vaccination took place and where?
SELECT TOP 1 location, MIN(date) AS FirstVaccinationDate
FROM covid_analysis_project..CovidVaccinations
WHERE new_vaccinations IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY FirstVaccinationDate


WITH PopulationvsVaccination (location, date, population, new_vaccinations, RollingVaccinationofPeople)
as
(
SELECT location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS RollingVaccinationofPeople
FROM covid_analysis_project..CovidVaccinations
WHERE continent IS NOT NULL
)

SELECT location, date, (RollingVaccinationofPeople / population) * 100 AS RollingVaccinationRate
FROM PopulationvsVaccination


DROP TABLE IF EXISTS #RollingVaccinationNumbers
CREATE TABLE #RollingVaccinationNumbers
(
continent nvarchar(50),
location nvarchar(50),
date date,
population numeric,
new_vaccinations numeric,
RollingVaccinationNumber numeric
)

INSERT INTO #RollingVaccinationNumbers
SELECT continent, location, date, population, new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS RollingVaccinationofPeople
FROM covid_analysis_project..CovidVaccinations
WHERE continent IS NOT NULL

SELECT * FROM #RollingVaccinationNumbers
ORDER BY 2,3


