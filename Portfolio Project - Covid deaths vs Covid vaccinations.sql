--Data exploration of Covid deaths vs vaccinations as of 2 October 2022

Select *
From [Portfolio Project]..coviddeaths
where continent is not null
Order by 3,4

--Select *
--From [Portfolio Project]..covidvaccinations
--Order by 3,4

-- Select the data that I will be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..coviddeaths
Order by 1, 2

--Total cases vs Total deaths
--Shows the percentage of the possiblity of dying when contracted with Covid in netherlands

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percent
From [Portfolio Project]..coviddeaths
Where location LIKE '%netherlands%'
Order by 1, 2

--Total Cases vs Population
--Shows total percentage of population contracted covid in netherlands

Select location, date, total_cases, population, (total_cases/population)*100 as hadCovid_Percent
From [Portfolio Project]..coviddeaths
Where location LIKE '%netherlands%'
Order by 1, 2

--Countries with higher infection rate compared to their population

Select location, population, MAX(total_cases) As highest_infection_count,  MAX((total_cases/population))*100 as Infection_Percent
From [Portfolio Project]..coviddeaths
Group by location, population
Order by Infection_Percent desc

--higher death count as per population per country

Select location, MAX(cast(total_deaths as int)) As total_death_count
From [Portfolio Project]..coviddeaths
where continent is not null
Group by location
Order by total_death_count desc

-- Doing per continent

Select continent, MAX(cast(total_deaths as int)) As total_death_count
From [Portfolio Project]..coviddeaths
where continent is not null
Group by continent
Order by total_death_count desc



Select location, MAX(cast(total_deaths as int)) As total_death_count
From [Portfolio Project]..coviddeaths
where continent is null
And location != 'high income' and location != 'Upper middle income' and location != 'Lower middle income' and location != 'Low income'
Group by location
Order by total_death_count desc

--Global stats

Select date, SUM(new_cases)as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as new_death_Percent
From [Portfolio Project]..coviddeaths
where continent is not null
Group by date
Order by 1, 2

Select SUM(new_cases)as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as new_death_Percent
From [Portfolio Project]..coviddeaths
where continent is not null
Order by 1, 2


--Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as Rolling_People_vaccinated, (Rolling_People_vaccinated/population)*100
from [Portfolio Project]..coviddeaths dea
	Join [Portfolio Project]..covidvaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	Order by 2, 3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinatios, Rolling_People_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as Rolling_People_vaccinated
from [Portfolio Project]..coviddeaths dea
	Join [Portfolio Project]..covidvaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (Rolling_People_vaccinated/population)*100
from PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_vaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as Rolling_People_vaccinated
from [Portfolio Project]..coviddeaths dea
	Join [Portfolio Project]..covidvaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null

Select *, (Rolling_People_vaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as Rolling_People_vaccinated
from [Portfolio Project]..coviddeaths dea
	Join [Portfolio Project]..covidvaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select * 
from PercentPopulationVaccinated


