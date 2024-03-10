select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccination
--order by 3,4


--- Selected data for further analysis

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--- Total Cases vs Total Deaths / people worldwide infected with Covid 19 who have died by 30.04.2021. (%)

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--- Infected people with Covid 19 in Croatia who died by 30.04.2021. (%)
--- Peak in June 2020
--- First death 19.03.2020.

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%croatia%' and continent is not null
order by 1,2


--- Total Cases vs Population
--- Percentage of the population with Covid 19

select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where Location like '%croatia%' and continent is not null
order by 1,2



--- Countries with the highest infection rate compared to their population

select Location, population, max(total_cases) as HighestInfCount, max((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by InfectedPercentage desc



--- Countries with the highest death count compared to their population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--- Continents with the highest death count in comparation to their population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--- Global numbers for Covid 19 cases per day

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercGlobal
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--- Global numbers for Covid 19

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercGlobal
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--- Cumulative number of new vaccination by dates and locations

select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations as int)) OVER(Partition by d.Location order by d.location, d.date ) as CumulativeVac
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2, 3


--- CTE


with PopulVsVac(continent, location, date, population, new_vaccinations, CumulativeVac)
as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations as int)) OVER(Partition by d.Location order by d.location, d.date ) as CumulativeVac
---(CumulativeVac/population)*100
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
on d.location = v.location
and d.date = v.date
where d.continent is not null
---order by 2, 3)
)
select *, (CumulativeVac/population)*100
from PopulVsVac


--- Temp table

create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVac numeric
)
insert into #PercentPeopleVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations as int)) OVER(Partition by d.location order by d.location, d.date ) as CumulativeVac
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
on d.location = v.location
and d.date = v.date
---where d.continent is not null


select *, (CumulativeVac/population)*100
from #PercentPeopleVaccinated


--- View for later visualizations

Create View PercentPopulationVaccinated as
select 
d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int, v.new_vaccinations)) OVER(Partition by d.location order by d.location, d.date ) as CumulativeVac
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
on d.location = v.location
and d.date = v.date

select *
from PercentPopulationVaccinated

