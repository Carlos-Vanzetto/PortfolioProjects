-- Covid mortality

SELECT location, date, total_cases, total_deaths,  try_convert(numeric(38,12), total_deaths)/try_convert(numeric(38,12),total_cases)*100 as Mortality
FROM PortfolioProject..covidDeaths
WHERE location like '%argentina%'
ORDER BY 1, 2

SELECT location, date, Population, total_cases, try_convert(numeric(38,12), total_cases)/Population*100  AS infectedVsPop
FROM PortfolioProject..covidDeaths
WHERE location = 'Argentina'
ORDER BY 1,2 

-- Looking at countries with highest infection rate compared to population


SELECT location, Population, MAX(try_convert(int, total_cases)) AS HighestInfectionCount, MAX(try_convert(numeric(38,12), total_cases)/Population*100)  AS infectedVsPop
FROM PortfolioProject..covidDeaths
GROUP BY location, population
ORDER BY infectedVsPop DESC

-- Total death count per country

SELECT location, max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC

-- Total death count per continent


SELECT location, max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is null and location  not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC



SELECT sum(cast(total_cases as bigint)) as GlobalTotalCases, sum(cast(Total_deaths as bigint)) AS GlobalTotalDeathCount, sum(cast(Total_deaths as bigint))/sum(cast(total_cases as bigint))*100 AS GlobalMortality
FROM PortfolioProject..covidDeaths
WHERE continent is not null 


SELECT sum(TRY_CONVERT(bigint,total_cases)) as GlobalTotalCases, sum(TRY_CONVERT(bigint,Total_deaths)) AS GlobalTotalDeathCount, sum(TRY_CONVERT(bigint,Total_deaths))/sum(TRY_CONVERT(bigint,total_cases)) AS GlobalMortality
FROM PortfolioProject..covidDeaths
WHERE continent is not null 

SELECT 
    SUM(new_cases) AS GlobalTotalCases, 
    SUM(new_deaths) AS GlobalTotalDeathCount, 
	SUM(new_deaths)/SUM(new_cases)*100  AS GlobalMortality
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL

-- Looking at total population vs vaccionation
-- Using CTE

WITH popvsVac (continent, location, date, population, new_vaccinations, cumulative_vaccinations_per_loc)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations_per_loc
FROM PortfolioProject..covidVaccination vac
 JOIN PortfolioProject..covidDeaths dea
	ON vac.location = dea.location  
	and vac.date = dea.date
WHERE dea.continent is not null
and dea.location = 'Brazil'
ORDER BY 2,3
)
SELECT *, (cumulative_vaccinations_per_loc/population)*100 as vaccinatedVSPopulation  from popvsVac


---- Using TEMP TABLE
DROP TABLE IF EXISTS #PopulationVsVaccines
CREATE TABLE #PopulationVsVaccines (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativeVaccinations numeric)

INSERT INTO #PopulationVsVaccines 
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations_per_loc
FROM PortfolioProject..covidVaccination vac
 JOIN PortfolioProject..covidDeaths dea
	ON vac.location = dea.location  
	and vac.date = dea.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (cumulativeVaccinations/population)*100 as vaccinatedVSPopulation  from #PopulationVsVaccines
ORDER BY 2,3
 

 -- CREATING A VIEW 

-- CREATE VIEW popVSvaccines AS
-- SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations ,
--SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations_per_loc
--FROM PortfolioProject..covidVaccination vac
-- JOIN PortfolioProject..covidDeaths dea
--	ON vac.location = dea.location  
--	and vac.date = dea.date
--WHERE dea.continent is not null


SELECT * FROM popVSvaccines