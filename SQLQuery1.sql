--This quary is based on the covid data sourced FROM ourworldindata.org site. The used data sheet include details LIKE, covid cASes,
--number of deaths and vaccination data.

SELECT *
FROM PortfolioProject_1..covid_deaths
ORDER BY 3,4
	
--SELECT the data which is need to working with

SELECT location,date,total_cASes,new_cASes,total_deaths,population
FROM PortfolioProject_1..covid_deaths
ORDER BY 1,2

--Looking at toal cASes vs total deaths
--Shows the posibility of dying if someone contract covid in his or her country

SELECT location,date,total_cASes,total_deaths, (total_deaths/total_cASes)*100 AS DeathPersentage
FROM PortfolioProject_1..covid_deaths
WHERE location LIKE '%states%'
ORDER BY 1,2

SELECT location,date,total_cASes,total_deaths, (total_deaths/total_cASes)*100 AS DeathPersentage
FROM PortfolioProject_1..covid_deaths
WHERE location LIKE '%sri lanka%'
ORDER BY 1,2

--Looking at total cASes vs population

SELECT location,date,population,total_cASes, (total_cASes/population)*100 AS DeathPersentage
FROM PortfolioProject_1..covid_deaths
WHERE location LIKE '%sri lanka%'
ORDER BY 1,2

--Looking at total cASes vs population in the world

SELECT location,date,population,total_cASes, (total_cASes/population)*100 AS PercentPopulationInfected
FROM PortfolioProject_1..covid_deaths
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population,Max(total_cASes) AS HighestInfectionCount, MAX((total_cASes/population)*100) AS PercentPopulationInfected
FROM PortfolioProject_1..covid_deaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing countries with highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject_1..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Break things down by continent
--Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject_1..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers

SELECT date, SUM(new_cASes) AS Total_CASes, SUM(new_deaths) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cASes)*100 AS DeathPersentage
FROM PortfolioProject_1..covid_deaths
WHERE continent IS NOT NULL  AND new_deaths >0 AND new_cASes >0 AND new_deaths IS NOT NULL AND new_cASes IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Retrive data FROM Covid_Vaccination sheet
--Looking at total population vs vaccinations

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 FROM PortfolioProject_1..covid_deaths dea
 JOIN PortfolioProject_1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
 
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollongPeopleVaccinated

 FROM PortfolioProject_1..covid_deaths dea
 JOIN PortfolioProject_1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

--Use CTE(Common table expression)

WITH PopvsVac (continent, location,date,population,new_vaccinations,RollongPeopleVaccinated)
AS
(SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollongPeopleVaccinated

 FROM PortfolioProject_1..covid_deaths dea
 JOIN PortfolioProject_1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)

SELECT*, (RollongPeopleVaccinated/population)*100
FROM PopvsVac


--Temporary table

DROP TABLE IF EXISTS #PercentopulationVaccinatedd
CREATE TABLE #PercentopulationVaccinatedd
(

continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollongPeopleVaccinated numeric
)

INSERT  #PercentopulationVaccinatedd
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollongPeopleVaccinated

 FROM PortfolioProject_1..covid_deaths dea
 JOIN PortfolioProject_1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT*,(RollongPeopleVaccinated/population)*100
FROM #PercentopulationVaccinatedd

CREATE VIEW PercentopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollongPeopleVaccinated

 FROM PortfolioProject_1..covid_deaths dea
 JOIN PortfolioProject_1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3



