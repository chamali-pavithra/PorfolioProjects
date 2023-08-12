
select *
from PortfolioProject_1..covid_deaths
order by 3,4

--select *
--from PortfolioProject_1..covid_vaccinations
--order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject_1..covid_deaths
order by 1,2

--Looking at toal cases vs total deaths
--Shows the posibility of dying if you contract covid in your country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPersentage
from PortfolioProject_1..covid_deaths
Where location like '%states%'
order by 1,2

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPersentage
from PortfolioProject_1..covid_deaths
Where location like '%sri lanka%'
order by 1,2

--Looking at total cases vs population

select location,date,population,total_cases, (total_cases/population)*100 AS DeathPersentage
from PortfolioProject_1..covid_deaths
Where location like '%sri lanka%'
order by 1,2

--Looking at total cases vs population in the world

select location,date,population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
from PortfolioProject_1..covid_deaths
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population,Max(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
from PortfolioProject_1..covid_deaths
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

select location, MAX(total_deaths) AS TotalDeathCount
from PortfolioProject_1..covid_deaths
WHERE continent is not null
Group by location
order by TotalDeathCount desc

--Break things down by continent
--Showing continents with the highest death count per population

select continent, MAX(total_deaths) AS TotalDeathCount
from PortfolioProject_1..covid_deaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers

select date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPersentage
from PortfolioProject_1..covid_deaths
WHERE continent is not null  AND new_deaths >0 AND new_cases >0 AND new_deaths is not null AND new_cases is not null
Group by date
order by 1,2

--Retrive data from Covid_Vaccination sheet

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
(
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
)

SELECT*, (RollongPeopleVaccinated/population)*100
FROM PopvsVac





--Temporary table

DROP table if exists #PercentopulationVaccinatedd
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



