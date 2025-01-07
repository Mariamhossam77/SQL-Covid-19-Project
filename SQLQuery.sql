use covid_19;

--1.Data Exploration

--select Featured Columns
select continent,location,date,total_cases,
new_cases,total_deaths,
population 
from Covid_Deaths
where continent is not null
order by 3;

select * from Covid_Deaths where continent is null;

select count(*) from Covid_Deaths;


--2.Data Cleaning:
--By Analyzing and exploring the data...when continent is NULL...the location value is continent instead of country
--so delete these rows will increase data integrity 

delete from Covid_Deaths where continent is null;

select count(*) from Covid_Deaths;



--3.Answer Business Questions

--Total Cases VS Total Deaths
--1.show the Likelihood of dying if you contract covid in your country
select location,date,total_cases,
total_deaths,
(total_deaths/total_cases)*100 as [death persentage]
from Covid_Deaths
where location like '%Egypt%'
order by 1,2;


--Total Cases VS Population
--2.Show What Persentage Of Population Got COVID Along Time 
select location,date,total_cases,
population,
(total_cases/population)*100 as [Infection Persentage]
from Covid_Deaths
order by location,date ;



--3.Looking at the countries with the highest Infection Rate compared to Population

select location,population,MAX(total_cases) as [Total Cases],
max(total_cases/population)*100 as [Highest Infection Rate]
from Covid_Deaths
group by location,population
order by [Highest Infection Rate] desc;



--4.Showing Countries With Highest Death Count Per Population
--**THERE IS A PROBLEM IN COLUMN (TOTAL_DEATH) AS IT IS NVARCHAR(255),SO THE ORDER BY IS NOT ACCURATE**
--**THE SOLUTION IS CASTING THE TOTAL_DEATH COLUMN INTO INT**

select location,population,max(cast(total_deaths as bigint)) as [Number Of Death]
from Covid_Deaths
group by location,population
order by [Number Of Death] desc;

--5.Show which day has most number of Infections
select date ,sum(new_cases) as Total_new_cases_per_Day from Covid_Deaths
group by date
order by date desc

--6.Show which month has most number of Infections
select month(date) as Months ,sum(new_cases) as Total_new_cases_per_month from Covid_Deaths
group by month(date)
order by month(date) desc

--7.Show which month has more number of deaths
select month(date) as Months ,sum(convert(int,new_deaths)) as Total_new_deaths_per_month from Covid_Deaths
group by month(date)
order by month(date) desc
--NOTEEEE ????? By Analyzing....december has most number of Infections and deaths

--8.Show which Year has most number of Infections
select year(date) as Years ,sum(convert(int,new_cases)) as Total_new_cases_per_year from Covid_Deaths
group by year(date)
order by Total_new_cases_per_year desc

--9.Show which Year has most number of deaths
select year(date) as Years ,sum(convert(int,new_deaths)) as Total_new_deaths_per_year from Covid_Deaths
group by year(date)
order by Total_new_deaths_per_year desc

--NOTEEEE ????? By Analyzing... 2020 has most number of Infections and deaths....Things got better in 2021





--10.let's see which continent  has the highest number of death
select continent,max(cast(total_deaths as int)) AS [Number of Death]
from Covid_Deaths
group by continent
order by [Number of Death] desc;



--11.which dayyy Has the Highest Infection cases
select date,sum(new_cases) as [Total new cases] ,sum(cast(new_deaths as int)) as [Total New Deaths]
from Covid_Deaths
where continent is not null
group by date
order by [Total new cases] desc;


--12.Show persentage of new death over new cases per day
--Handling Dividing By Zero In Two Methods
--1.using Case When

select date,
case WHEN sum(new_cases) = 0 THEN NULL -- Replace NULL with a default value if needed
        ELSE (sum(cast(new_deaths as int))/sum(new_cases))*100
end division_result
from Covid_Deaths
group by date
order by 1;


--2.Using NullIF
select date,
(sum(cast(new_deaths as int))/ NULLIF(sum(new_cases), 0))*100  [Division new deaths to new cases]
from Covid_Deaths
group by date
order by 1;


--Include total cases and total death columns
select date,
sum(new_cases) as [Total New Cases],
sum(CAST(new_deaths as Int)) AS [Total New Deaths],
(sum(CAST(new_deaths as Int))/nullif(sum(new_cases),0))*100  AS [Division new deaths to new cases]
from Covid_Deaths
where continent is not null
group by date
order by 1;


--world new cases and new deaths

select 
sum(new_cases) as [Total New Cases],
sum(CAST(new_deaths as Int)) AS [Total New Deaths],
(sum(CAST(new_deaths as Int))/nullif(sum(new_cases),0))*100  AS [Division new deaths to new cases]
from Covid_Deaths
where continent is not null
order by 1;



--select featured columns from Covid_Vaccinations
select continent,location,date,
total_vaccinations,people_vaccinated,
people_fully_vaccinated,new_vaccinations from Covid_Vaccinations
order by location,date;

select * from Covid_Vaccinations where continent is null;


----By Analyzing and exploring the data...when continent is NULL...the location value is continent instead of country
--so delete these rows will increase data integrity 
delete from Covid_Vaccinations where continent is null;



--join covid vaccinations and covid deaths tables
--I join two tables continuously. SO Let's do CTE(Common Table Expression)
with covid_deaths_Vaccinations AS(
select cd.continent,cd.location,cd.date,cd.population,cd.new_cases,cd.new_deaths,
cv.new_vaccinations,cv.total_vaccinations,cv.people_vaccinated 
from Covid_Deaths cd join 
Covid_Vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date)

SELECT *
FROM covid_deaths_Vaccinations;



--13.look at the total population vs new_vaccination for every day
select cd.location,cd.date,population,cv.new_vaccinations from Covid_Deaths cd
join Covid_Vaccinations cv
on cd.location = cv.location
and cd.date = cv.date
order by location,date;


--14.view total new_Vacination in each country..Using Aggregation Function
with covid_deaths_Vaccinations AS(
select cd.continent,cd.location,cd.date,cd.population,cd.new_cases,cd.new_deaths,
cv.new_vaccinations,cv.total_vaccinations,cv.people_vaccinated 
from Covid_Deaths cd join 
Covid_Vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date)

select location,sum(convert(int,new_vaccinations)) AS [Total New vaccinations] 
from covid_deaths_Vaccinations
group by location
order by [Total New vaccinations] desc;


--Alter new_vaccinations column into int instead of nvarchar to do aggregation functions easier
ALTER TABLE Covid_Vaccinations ALTER COLUMN new_vaccinations INT;

--15.view total new_Vacination in each country..Using WIndowing Fucntion (ROLLING COUNT)

with covid_deaths_Vaccinations AS(
select cd.continent,cd.location,cd.date,cd.population,cd.new_cases,cd.new_deaths,
cv.new_vaccinations,cv.total_vaccinations,cv.people_vaccinated 
from Covid_Deaths cd join 
Covid_Vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date)

select continent,location,
date,population,new_vaccinations,
sum(new_vaccinations) over(partition by location order by location,date ) AS [Total vaccinations (Rolling Count)]
from covid_deaths_Vaccinations;

--16.Divide Max Rolling Count by population to know how much persentage per country got Vaccinated
with covid_deaths_Vaccinations AS(
select cd.continent,cd.location,cd.date,cd.population,cd.new_cases,cd.new_deaths,
cv.new_vaccinations,cv.total_vaccinations,cv.people_vaccinated 
from Covid_Deaths cd join 
Covid_Vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date)

--Using SubQuery
select location,(max([total new vaccinations ])/population)*100 as [Vaccinated Persentage] from (
select continent,location,date,population,new_vaccinations,
sum(new_vaccinations) over(partition by location order by location, date) as [total new vaccinations ]
from covid_deaths_Vaccinations )t
group by population,location
order by [Vaccinated Persentage] desc


--AS Number of Population Across The World Wide is Important so we're gonna put it in View

CREATE VIEW TotalPopulation AS
SELECT SUM([Population per county]) AS [Total Population]
FROM (
    SELECT location, MAX(population) AS [Population per county]
    FROM Covid_Deaths
    GROUP BY location
) t;

select * from TotalPopulationView;





--Convert people_vaccinated from nvarchar to bigint
alter table Covid_Vaccinations alter column people_vaccinated  bigint;

--17.Show persentage of people got vaccinated in each country 
with covid_deaths_Vaccinations AS(
select cd.continent,cd.location,cd.date,cd.population,cd.new_cases,cd.new_deaths,
cv.new_vaccinations,cv.total_vaccinations,cv.people_vaccinated 
from Covid_Deaths cd join 
Covid_Vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date)


select location,round(max([Total People vaccinated per country]/population)*100,1) as [Vaccinated people per country]
from (
	  select location,date,population,
	  max(people_vaccinated) over(partition by location) as [Total People vaccinated per country]
	  FROM covid_deaths_Vaccinations)t
group by location
order by [Vaccinated people per country] desc





--18.put total people vaccinated in world wide in a VIEW
create view totalpeople_vaccinated AS
select sum([total people vaccinated per country]) as [total people vaccinated in world wide] from(
select location,
	  max(people_vaccinated) as [total people vaccinated per country]
	  FROM covid_Vaccinations
	  group by location
	  )t


select * from totalpeople_vaccinated; 


--19.Compare world wide population and world wide people vaccinated
SELECT
    (SELECT * FROM totalpeople_vaccinated) AS [total people vaccinated in WW],
    (SELECT * FROM TotalPopulation) AS [Total Population in WW];

--20.FINALLYYY: What percentage of people in the world are vaccinated? (COMBINE BOTH VIEWS)
  select
    round(((SELECT * FROM totalpeople_vaccinated)/(SELECT * FROM TotalPopulation))*100,1) as [percentage of people in the world are vaccinated]


















