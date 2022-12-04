/*
Our World In Data - Coronavirus (COVID-19) Deaths

Table of Contents
 - Part 1: Data Exploration
 - Part 2: Data Visualization
*/

/*
 * Part 1: Data Exploration
 */

-- Exploring the data.
SELECT * -- Retrieve all data from the database.
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> '' OR continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).
ORDER BY 3, 4 -- Order by location and date.


-- Exploring the data.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%' -- Use this WHERE clause to only retrieve data for the United States.
ORDER BY 1, 2 -- Order by location and date.


-- Looking at total cases versus total deaths.
-- DeathPercentage shows the likelihood of dying if you contract covid in a given country.
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> '' OR continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).
ORDER BY 1, 2 -- Order by location and date.


-- Looking at total cases versus population.
-- PercentPopulationInfected shows the percentage of the population infected with covid.
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> '' OR continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).
ORDER BY 1, 2 -- Order by location and date.


-- Looking at countries with the highest infection rate compared to the population.
-- PercentPopulationInfected shows the percentage of the population infected with covid.
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> '' OR continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).
GROUP BY location, population -- Group by location and population.
ORDER BY PercentPopulationInfected DESC -- Sort by PercentPopulationInfected in descending order.


-- Comparing countries with the highest death count per population.
-- TotalDeathCount shows the total number of people who died from coronavirus.
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount -- Convert the data type of the total_deaths column to integer.
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> '' OR continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).
GROUP BY location
ORDER BY TotalDeathCount DESC -- Sort by TotalDeathCount in descending order.


-- BREAKING THINGS DOWN BY CONTINENT.


-- Showing continents with the highest death count per population.
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount -- Convert the data type of the total_deaths column to integer.
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> '' OR continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).
GROUP BY continent -- Group by continent.
ORDER BY TotalDeathCount DESC -- Sort by TotalDeathCount in descending order.


-- Showing continents and other locations (low income, high income, etc.) with the highest death count per population.
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount -- Convert the data type of the total_deaths column to integer.
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent = '' OR continent = NULL -- Filter by locations that are countries.
GROUP BY location -- Group by location.
ORDER BY TotalDeathCount DESC -- Sort by TotalDeathCount in descending order.


-- GLOBAL NUMBERS.


-- Looking globally at total cases versus total deaths.
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> '' OR continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).
GROUP BY date
ORDER BY 1, 2 -- Sort by date and total_cases in ascending order (ASC is the default sorting order).


-- Looking globally at total cases versus total deaths.
-- Remove the date column to only show one row of data.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> '' OR continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).


-- Looking at total population versus vaccinations.
-- Combine both tables using an inner join.
-- New_vaccinations displays the number of vaccinations administered on a given date.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea -- Create an alias for the CovidDeaths table, here "dea".
JOIN PortfolioProject.dbo.CovidVaccinations vac -- Create an alias for the CovidVaccinations table, here "vac".
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> '' OR dea.continent <> NULL -- Filter out locations that are not countries (World, Europe, etc.).
ORDER BY 2, 3 -- Order by location and date.


-- Creating a "rolling count" of new vaccinations by using a Common Table Expression (CTE) named PopvsVac.
-- A CTE is needed here, because you can't use a column that you've just created and use it in the next one, here RollingPeopleVaccinated.
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
-- Create a "rolling count" of new vaccinations by using a SUM function and a PARTITION BY clause.
-- Break the locations up by using a PARTITION BY clause, so that every time you get to a new location, the aggregate function starts over.
-- CAST and CONVERT do basically the same.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100 -- This can't be calculated here, but in the next SELECT clause.
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> '' OR dea.continent <> NULL
--ORDER BY 2, 3 -- No need for ordering here.
)
SELECT *, (RollingPeopleVaccinated / population) * 100 -- Calculate the percentage of people vaccinated relative to the total population.
FROM PopvsVac


-- Creating a "rolling count" of new vaccinations by using a temporaty table.
DROP TABLE IF EXISTS #PercentPopulationVaccinated -- Delete the temp table if it already exists, this can be useful if you execute this code multiple times.
CREATE TABLE #PercentPopulationVaccinated -- Create a temporary table named #PercentPopulationVaccinated.
(
continent nvarchar(255), -- Create new columns by defining column header and data type.
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations float,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
-- Create a "rolling count" of new vaccinations by using a SUM function and a PARTITION BY clause.
-- Break the locations up by using a PARTITION BY clause, so that every time you get to a new location, the aggregate function starts over.
-- CAST and CONVERT do basically the same.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100 -- This can't be calculated here, but in the next SELECT clause.
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent <> '' OR dea.continent <> NULL -- No need for filtering by continent here.
--ORDER BY 2, 3 -- No need for ordering here.
SELECT *, (RollingPeopleVaccinated / population) * 100 -- Calculate the percentage of people vaccinated relative to the total population.
FROM #PercentPopulationVaccinated


-- Creating a view to store data in for later visualizations.
-- A view is a virtual table whose contents are defined by a query.
-- CAST and CONVERT do basically the same.
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100 -- This can't be calculated here, but in the next SELECT clause.
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> '' OR dea.continent <> NULL
--ORDER BY 2, 3 -- No need for ordering here.

-- Retrieve the data from the view PercentPopulationVaccinated.
SELECT *, (RollingPeopleVaccinated / population) * 100 -- Calculate the percentage of people vaccinated relative to the total population.
FROM PercentPopulationVaccinated


/*
 * Part 2: Data Visualization
 * These are the SQL queries used for the data visualizations in Tableau.
 */


-- 1. Looking at total cases versus total deaths.
-- DeathPercentage shows the likelihood of dying if you contract covid in a given country.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent <> NULL OR continent <> ''
ORDER BY 1,2


-- 2. Looking at total deaths per continent.
-- TotalDeathCount shows the total number of people who died from coronavirus per continent.
-- Filter out locations that doesn't count as continent (European Union, high income, etc.).
-- Here, Europe includes the European Union.
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent = NULL OR continent = ''
AND location NOT IN ('European Union', 'High income', 'International', 'Low income', 'Lower middle income', 'Upper middle income', 'World')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3. Looking at countries with the highest infection rate compared to the population.
-- PercentPopulationInfected shows the percentage of the population infected with covid.
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4. Looking at countries with the highest infection rate compared to the population.
-- Include the date column to retrieve daily values.
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC
