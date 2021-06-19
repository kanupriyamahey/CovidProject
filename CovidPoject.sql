SELECT * FROM PortfolioProject.dBo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT * FROM PortfolioProject.dBo.CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Total Cases vs Total Deaths

SELECT Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Canada%' AND continent is NOT NULL
ORDER BY 1,2

--Total Cases vs Population

SELECT Location, date,  population, total_cases,  (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Canada%' AND continent is NOT NULL
ORDER BY 1,2

--Countries with highest Infection Rate compared to population
 SELECT Location, population, MAX(total_cases) AS HighestCount, MAX(total_cases/population)*100 AS InfectedPopulationPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location, population
ORDER BY InfectedPopulationPercent DESC

--Countries with highest death count per population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Death Counts by Continents
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NEW CASES AND DEATHS BY DATE
SELECT date, SUM(new_cases) AS total_NewCases, SUM(CAST(new_deaths AS INT)) AS Total_NewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS NewDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date 
ORDER BY 1 DESC

--TOTAL GLOBAL CASES AND DEATHS 
SELECT SUM(total_cases) AS Total_Cases, SUM(CAST(total_deaths AS INT)) AS Total_Deaths, SUM(CAST(total_deaths AS INT))/SUM(total_cases) AS DeathsPerCases
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL

--Total Populations vs Vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--Total Population vs Vaccinations

WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS percentageVaccinated From PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS percentageVaccinated FROM #PercentPeopleVaccinated

--VIEW for Visualization
CREATE VIEW PercentPopVacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT * FROM PercentPopVacc



