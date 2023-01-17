--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

select * 
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the likelhood of dying if you contract covid in your country 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
Where Location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
Where Location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to  Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--Where Location like '%states%'
group by Location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--Where Location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc

--Breaking things down by Continent 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where Location like '%states%'
where continent is not null
GROUP BY date
order by 1,2


-- Looking at Total Population vs Vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac,new_vaccinations
, SUM(Convert(numeric,vac,new_vaccinations)), OVER(Partition by dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated, 
--(RollingPeopleVaccinated/population)100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated 
