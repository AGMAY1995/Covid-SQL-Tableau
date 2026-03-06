-- select the data we are going to be using

/*
select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from CovidDeaths
order by 1, 2
*/

-- LOOKING AT TOTAL CASES vs TOTAL DEATHS
-- SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

/*
select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths / total_cases)*100 AS DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1, 2
*/

-- LOOKING AT TOTAL CASES vs THE POPULATION
-- SHOWS WAHT PERCENTAGE OF POPULATION GOT COVID

/*
select 
	location,
	date,
	population,
	total_cases,
	(total_cases / population)*100 AS Cases_per_Population
from CovidDeaths
where location like '%states%'
order by 1, 2
*/

-- WHAT COUNTRIES HAVE THE HIGHEST INFECTION RATE COMPARED TO POPULATION

/*
select
	location,
	population,
	max(total_cases) AS HighestInfectionCount,
	max(total_cases / population)*100 AS PercentPopulationInfected
from CovidDeaths
Group by 
	Location,
	Population
order by 
	PercentPopulationInfected desc
*/

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

/*
select
	location,
	max(cast(total_deaths as int)) AS TotalDeathCount
from CovidDeaths
where continent is not null
Group by 
	Location
order by 
	TotalDeathCount desc
*/

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT

/*
select
	continent,
	max(cast(total_deaths as int)) AS TotalDeathCount
from CovidDeaths
where continent is not null
Group by 
	continent
order by 
	TotalDeathCount desc
*/

-- GLOBAL NUMBERS

/*
select 
	sum(new_cases) AS TotalCases,
	sum(cast(new_deaths as int)) AS TotalDeaths,
	sum(cast(new_deaths as int))/sum((new_cases))*100 AS DeathPercentage
from CovidDeaths
where continent is not null
--group by
--	date
order by 1, 2
*/

-- COVID VACCINATIONS DATA SET

-- LOOKING AT TOTAL POPULATION vs VACCINATION

/*
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3 
*/

-- USE CTE

/*
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 
)
select *,
	 (RollingPeopleVaccinated/Population)*100
from PopvsVac
*/

-- TEMP TABLE

/*
DROP Table if exists #PercentPopulationVaccinated -- IF YOU NEED TO MODIFY ANY COLUMN IN THE QUERY 
create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 

select *,
	 (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
*/

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

create view PercentPopulationVaccinated as
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3  

Select *
From PercentPopulationVaccinated