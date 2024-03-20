
Select *
from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from Portfolioproject..Covidvaccinations
--order by 3,4

--select data that we are going to be using

Select Location, date,total_cases, new_cases, total_deaths, population
from Portfolioproject..CovidDeaths
where continent is not null
order by 1,2




--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in ypur country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2



--looking at total cases vs population
--shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/Population)*100 as percentpopulationinfected
from Portfolioproject..CovidDeaths
--where location like '%states%'
order by 1,2



--looking at the country with highest infection rate compared to population 

Select Location, Population, MAX(total_cases)as highestinfectioncount, MAX((total_cases/Population))*100 as percentpopulationinfected
from Portfolioproject..CovidDeaths
--where location like '%states%'
group by Location, Population
order by percentpopulationinfected desc



--showing country with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as totaldeathcount
from Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by totaldeathcount desc



--lets break things down by continent

--showing continent with highest death counts

Select location, MAX(cast(total_deaths as int)) as totaldeathcount
from Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc



--global numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at totalpopulation vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths dea
JOIN  Portfolioproject..Covidvaccinations vac
  ON dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
order by 2,3



--CTE

with popvsvac(continent, location, date, population,new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths dea
JOIN  Portfolioproject..Covidvaccinations vac
  ON dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac




--temp table

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths dea
JOIN  Portfolioproject..Covidvaccinations vac
  ON dea.location = vac.location 
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentagepopulationvaccinated




---creating a view to store data for later visaulization

create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths dea
JOIN  Portfolioproject..Covidvaccinations vac
  ON dea.location = vac.location 
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentagepopulationvaccinated




