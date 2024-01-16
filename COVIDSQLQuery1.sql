Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Alter table PortfolioProject..CovidDeaths
--Alter column total_deaths float

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2

--Looking at total cases vs population
--Percentage of population that has had covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentageOfInfection
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2

--Looking at countries with highest rate of infection compared to population

Select location, MAX(total_cases) as HighestInfections, population, MAX(total_cases/population)*100 as PercentagePopuationInfected
From PortfolioProject..CovidDeaths
Group by location, population 
order by PercentagePopuationInfected desc


--Countries with highest death count

Select location, Max(total_deaths) as HighestDeaths
From PortfolioProject..CovidDeaths
where continent <> ''
Group by location
order by HighestDeaths desc

--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with highest death count
Select location, Max(total_deaths) as HighestDeaths
From PortfolioProject..CovidDeaths
--Where location = 'United States'
where continent = '' and location <> 'World'
Group by location
order by HighestDeaths desc

--Percentage of population infected by continent
Select location, population, MAX(total_cases) as Infections,  MAX(total_cases/population)*100 as PercentagePopuationInfected
From PortfolioProject..CovidDeaths
where continent = '' and location <> 'World' 
Group by location, population 
order by PercentagePopuationInfected desc

--Global Numbers

--Death percentage of global cases by day
Select date, Sum(new_cases) as Total_cases, Sum(Cast(new_deaths as int)) as Total_deaths, Sum(Cast(new_deaths as int))/nullif(Sum(new_cases),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent <> ''
Group by date
order by 1,2

--Total cases reported, total deaths reported, and death percentage
Select Sum(new_cases) as Total_cases, Sum(Cast(new_deaths as int)) as Total_deaths, Sum(Cast(new_deaths as int))/nullif(Sum(new_cases),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent <> ''
order by 1,2


--Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location, dea.date) TotalVaxbyDate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent <> ''
	order by 2,3


	-- Using CTE
	 With PopvsVac (continent, location, date, population, new_vaccinations, TotalVaxbyDate)
	 as
	(
	 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(float,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as TotalVaxbyDate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent <> ''
	)

	Select *, (TotalVaxbyDate/population)*100
	From PopvsVac

	--Using temp table
	Drop table if exists #PercentageOfpopulationvax
	Create Table #PercentageOfpopulationvax
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	Population float,
	new_vaccinations nvarchar(255),
	RollingPeopleVax float
	)

	Insert into #PercentageOfpopulationvax
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(float,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as TotalVaxbyDate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent <> ''

	Select *, (RollingPeopleVax/population)*100
	From #PercentageOfpopulationvax

--Creating view to store data for later visualizations
--Create view PercentagePopulationVax as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum( cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location, dea.date) TotalVaxbyDate
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--	Where dea.continent <> ''
	
--Create view PercentageInfectedbyContinent as
--Select location, population, MAX(total_cases) as Infections,  MAX(total_cases/population)*100 as PercentagePopuationInfected
--From PortfolioProject..CovidDeaths
--where continent = '' and location <> 'World' 
--Group by location, population
