--import coviddeath data from excel as csv file

CREATE TABLE Coviddeath (
	iso_code varchar (100),
	continent varchar (100),
	location varchar (100),
	date date,
	total_cases float ,
	 new_cases float ,
	 new_cases_smoothed float,
	total_deaths float,
	new_deaths float,
	new_deaths_smoothed float,
	total_cases_per_million float,
	new_cases_per_million float,
	new_cases_smoothed_per_million float ,
	total_deaths_per_million float,
	new_deaths_per_million float,
	new_deaths_smoothed_per_million float,
	reproduction_rate float ,
	icu_patients float,
	icu_patients_per_million float,
	hosp_patients float,
	hosp_patients_per_million float,
	weekly_icu_admissions float,
	weekly_icu_admissions_per_million float,
	weekly_hosp_admissions float,
	weekly_hosp_admissions_per_million float,
	new_tests float,
	total_tests float,
	new_tests_per_thousand float,
	new_tests_smoothed float,
	new_tests_smoothed_per_thousand float,
	positive_rate float ,
	tests_per_case float,
	tests_units varchar (100),
	total_vaccinations float,
	people_vaccinated float,
	people_fully_vaccinated float,
	new_vaccinations float,
	new_vaccinations_smoothed float,
	total_vaccinations_per_hundred float,
	people_vaccinated_per_hundred float,
	people_fully_vaccinated_per_hundred float,
	new_vaccinations_smoothed_per_million float,
	stringency_index float,
	population int,
	population_density float,
	median_age float,
	aged_65_older float,
	aged_70_older float,
	gdp_per_capita float,
	extreme_poverty float,
	cardiovasc_death_rate float,
    diabetes_prevalence float,
    female_smokers float,
     male_smokers float,
     handwashing_facilities float,
     hospital_beds_per_thousand float,
     life_expectancy float,
     human_development_index float
)

--copy coviddeaths from 'C:\Users\owner\Downloads\covidDeaths.csv' with csv header;

select *
from coviddeath


--import covidvaccination data from excel as csv file

CREATE TABLE covidvacciantions 
(
  iso_code varchar (100),
   continent varchar (100),
   location varchar (100),
   date date,
   new_tests float,
   total_tests float,
   total_tests_per_thousand float,
   new_tests_per_thousand float,
   new_tests_smoothed float,
   new_tests_smoothed_per_thousand float,
   positive_rate float,
   tests_per_case float,
   tests_units varchar(100),
   total_vaccinations float,
   people_vaccinated float,
   people_fully_vaccinated float,
   new_vaccinations float,
   new_vaccinations_smoothed float,
   total_vaccinations_per_hundred float,
   people_vaccinated_per_hundred float,
   people_fully_vaccinated_per_hundred float,
   new_vaccinations_smoothed_per_million float,
   stringency_index float,
   population_density float,
   median_age float,
   aged_65_older float,
   aged_70_older float,
   gdp_per_capita float,
   extreme_poverty float,
   cardiovasc_death_rate float,
   diabetes_prevalence float,
   female_smokers float,
   male_smokers float,
   handwashing_facilities float,
   hospital_beds_per_thousand float,
   life_expectancy float,
   human_development_index float
)

--copy covidvaccinations from 'C:\Users\owner\Downloads\covidVaccinations.csv' with csv header;
select *
from covidvaccinations

--Looking at Total cases vrs Total deaths
--shows what percentage of population who died
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from  coviddeaths
where location = 'United States'
group by location, date, total_cases, total_deaths
order by 1,2

--looking at total cases vrs population
--shows what percentage of population got covid
select location,date,total_cases, population, (total_cases/population)*100 as populationpercentage
from  coviddeaths
where location = 'United States'
group by location, date, total_cases,population
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,Max(total_cases)as highinfectioncount,max((total_cases/population))*100 as infectedpopulationpercentage
from  coviddeaths
where continent is not null
group by location,population
order by infectedpopulationpercentage desc

--looking at countries with highest death count per population
select location,Max(cast(total_deaths as int)) as highdeathcount
from  coviddeaths
where continent is not null  
group by location
order by highdeathcount desc

--lets break things down by continent
select location,Max(cast(total_deaths as int)) as highdeathcount
from  coviddeaths
where continent is  null  
group by location
order by highdeathcount desc

--Global numbers
select sum(new_cases) as Totalcases, sum(new_deaths) as Totaldeaths, sum(new_deaths)/sum(new_cases)*100 as percent
FROM coviddeaths
where continent is not null
--group by date
--ORDER BY 1,2


--looking at Total Population vrs Vaccinations
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(cv.new_vaccinations)over (partition by cd.location order by cd.location, cd.date)
from coviddeaths cd
join covidvaccinations cv
   on cd.location = cv.location
   and cd. date = cv.date
where cd.continent is not null
--group by cd.location, cd.continent,cd.date,cd.population,cv.new_vaccinations
order by 2,3


--USING CTE
with popvrsvac (continent,location,date,popluation,new_vaccination)
as
(
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(cv.new_vaccinations)over (partition by cd.location order by cd.location, cd.date) as popvaccinated
--,(popvaccinated/popluation)*100
from coviddeaths cd
join covidvaccinations cv
   on cd.location = cv.location
   and cd. date = cv.date
where cd.continent is not null
--group by cd.location, cd.continent,cd.date,cd.population,cv.new_vaccinations
--order by 2,3
)
select *,(popvaccinated/popluation)*100 as percentage
from popvrsvac


--USING TEMP TABLE
Create temp Table Percentpopulationvaccinated
(
Continent varchar(100),
Location varchar(100),
Date date,
Population numeric,
New_vaccinations numeric,
popvaccinated numeric
)

insert into percentpopulationvaccinated
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(cv.new_vaccinations)over (partition by cd.location order by cd.location, cd.date) as popvaccinated
--,(popvaccinated/popluation)*100
from coviddeaths cd
join covidvaccinations cv
   on cd.location = cv.location
   and cd. date = cv.date
where cd.continent is not null
--group by cd.location, cd.continent,cd.date,cd.population,cv.new_vaccinations
--order by 2,3


select *,(popvaccinated/percentpopulationvaccinated.population)*100 as percentage
from percentpopulationvaccinated


--USING VIEWS
-- creating views to store data for later visualizations

create view percentpopulationvaccinated as
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(cv.new_vaccinations)over (partition by cd.location order by cd.location, cd.date) as popvaccinated
--,(popvaccinated/popluation)*100
from coviddeaths cd
join covidvaccinations cv
   on cd.location = cv.location
   and cd. date = cv.date
where cd.continent is not null
--group by cd.location, cd.continent,cd.date,cd.population,cv.new_vaccinations
--order by 2,3

select *
from percentpopulationvaccinated