Select *
From PortfolioProject..CovidDeaths$ 
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..['Covid Vaccinations'] 
--Order by 3,4

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths 
-- Shows the likelilihood of dying if you contract covid in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%' And continent is not null
order by 1,2


-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--Where location like '%states%'
order by 1,2 


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount , Max((total_cases/population))* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Population, Location
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location 
Order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1, 2

-- Worldwide Death Percentage

Select SUM(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1, 2


-- Looking at Total Population Vs Vaccinations


With PopsvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac

--Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255) ,
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentOfPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
