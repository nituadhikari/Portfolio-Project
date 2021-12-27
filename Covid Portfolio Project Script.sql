SELECT * FROM ['Covid Deaths$']
WHERE continent IS NOT NULL
ORDER BY 3,4



--SELECT * FROM ['Covid Vaccination$']
--ORDER BY 3,4

-- Select Data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ['Covid Deaths$']
ORDER BY 1,2


-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ['Covid Deaths$']
WHERE location like '%Canada%'
ORDER BY 1,2

-- Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as CasesbyPopulationPercentage
FROM ['Covid Deaths$']
WHERE location like '%Canada%'
ORDER BY 1,2


-- Countries with highest infection rate compared to population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as CasesbyPopulationPercentage
FROM ['Covid Deaths$']
--WHERE location like '%Canada%'
GROUP BY location, population
ORDER BY CasesbyPopulationPercentage desc


-- Continent with highest death count per population

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM ['Covid Deaths$']
--WHERE location like '%Canada%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Continient Stats
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM ['Covid Deaths$']
--WHERE location like '%Canada%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage  -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ['Covid Deaths$']
--WHERE location like '%Canada%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Total Population Vs Vax

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinvated
FROM CovidPortfolioProject..['Covid Deaths$'] AS dea
JOIN CovidPortfolioProject..['Covid Vaccination$'] AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
WITH PopVsVac (Continent, Location, Date, Population, new_Vaccinations, PeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinvated
FROM CovidPortfolioProject..['Covid Deaths$'] AS dea
JOIN CovidPortfolioProject..['Covid Vaccination$'] AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)
SELECT *, (PeopleVaccinated/Population)*100
FROM PopVsVac


-- TEMP Table
DROP Table if EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinvated
FROM CovidPortfolioProject..['Covid Deaths$'] AS dea
JOIN CovidPortfolioProject..['Covid Vaccination$'] AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (PeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create View for Visualizations

CREATE VIEW PercentPopulationVaccinated1 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinvated
FROM CovidPortfolioProject..['Covid Deaths$'] AS dea
JOIN CovidPortfolioProject..['Covid Vaccination$'] AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL



CREATE VIEW TotalPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinvated
FROM CovidPortfolioProject..['Covid Deaths$'] AS dea
JOIN CovidPortfolioProject..['Covid Vaccination$'] AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


CREATE VIEW GlobalDeaths AS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage  -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ['Covid Deaths$']
--WHERE location like '%Canada%'
WHERE continent IS NOT NULL
GROUP BY date
