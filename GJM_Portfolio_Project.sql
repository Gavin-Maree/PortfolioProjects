
Select *
From PortfolioProject..CovidDeaths
Order by 3,4


--Select *
--From PortfolioProject..CovidVacinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Showing the likelihood of dying if you contracted covid

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths
Where location like 'South Africa'
Order by 1,2

-- Looking at Total Cases vs Population
-- Showing percentage of population contracted covid

Select Location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'South Africa'
Order by 1,2

-- Looking at countries with highest infection rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount
, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc

-- Looking for highest death count per Population
-- Excluding continent sub totals

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Looking for death count by Continent
-- Showing Continents with higest death counts

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Overview
-- Showing the daily Death Percent

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercent
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Showing the global Death Percent
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths 
, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercent
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Population vs Vaccinations
-- Joining CovidDeaths & CovidVacinations tables and calculate rolling New Vaccinations

-- CTE

With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVacinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.date < '2021-10-01'
)
Select *, (RollingPeopleVaccinated/Population) * 100 as RollingPeopleVaccinatedPercent
From PopsvsVac

-- TEMP table

Drop Table if exists #PercentPopulationVaccinated -- Include should you wish to modify temp table later
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.date < '2021-10-01'

Select *, (RollingPeopleVaccinated/Population) * 100 as RollingPeopleVaccinatedPercent
From #PercentPopulationVaccinated
