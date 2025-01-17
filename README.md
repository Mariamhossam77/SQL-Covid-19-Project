# Covid 19 Analysis SQL Project

## Project Overview

**Project Title**: Covid 19 Analysis  
**Level**: Advanced 
**Database**: `Covid 19`


I worked on an advanced SQL project analyzing COVID-19 data, consisting of two tables with over 85,000 rows. The project involved extensive data exploration and cleaning, addressing null values using CASE statements and NULLIF, and ensuring data integrity with type conversions using CONVERT and CAST. I conducted in-depth analysis to answer critical business questions, such as identifying the total infected cases in my country, calculating the percentage of the population infected over time, and pinpointing countries with the highest infection and death rates relative to their populations. I also analyzed trends, such as identifying the months with the highest infections and deaths, as well as the continents most impacted by COVID-19 fatalities.

To achieve these insights, I leveraged a wide range of SQL techniques, including aggregation functions, GROUP BY, ORDER BY, and complex joins between tables. I used date functions to extract meaningful insights from temporal data, such as monthly and yearly trends. Views and Common Table Expressions (CTEs) were created for efficient query management and reusability. I utilized window functions for rolling counts across days, providing cumulative trends for infections and vaccinations. Additionally, I calculated total population figures and vaccination rates, revealing that only **7.7%** of the population was vaccinated by 2021. This comprehensive project showcased my ability to transform raw data into actionable insights through advanced SQL methodologies, making it a powerful example of my data analysis capabilities.


## Objectives

1. **Data Cleaning**: Identify and remove any records with missing or null values.
2. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
3. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `Covid 19`.

```sql
CREATE DATABASE Covid 19;
```

### 2. Data Exploration 📊

- **Record Count**: Determine the total number of records in the dataset.
- **select Featured Columns** : select most important and used columns in table.
- **Discover Problems**: Find out problems in dataset (Datatypes or Nulls).
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
--select Featured Columns:

select continent,location,date,total_cases,
new_cases,total_deaths,
population 
from Covid_Deaths
where continent is not null
order by 3;

select * from Covid_Deaths where continent is null;

select count(*) from Covid_Deaths;
```

### 3.Data Cleaning 🧹
**Delete Nulls**: By Analyzing and exploring the data...when continent is NULL...the location value is continent instead of country,so delete these rows will increase data integrity .
```sql

delete from Covid_Deaths where continent is null;

select count(*) from Covid_Deaths;

```


### 4.Answer Business Questions ❔❔


The following SQL queries were developed to answer specific business questions:

1. **Total Cases VS Total Deaths-show the Likelihood of dying if you contract covid in your country**:
```sql
select location,date,total_cases,
total_deaths,
(total_deaths/total_cases)*100 as [death persentage]
from Covid_Deaths
where location like '%Egypt%'
order by 1,2;
```

2. **Total Cases VS Population-Show What Persentage Of Population Got COVID Along Time**:
```sql
select location,date,total_cases,
population,
(total_cases/population)*100 as [Infection Persentage]
from Covid_Deaths
order by location,date ;
```

3. **Looking at the countries with the highest Infection Rate compared to Population**:
```sql
select location,population,MAX(total_cases) as [Total Cases],
max(total_cases/population)*100 as [Highest Infection Rate]
from Covid_Deaths
group by location,population
order by [Highest Infection Rate] desc;
```

4. **Showing Countries With Highest Death Count Per Population**
**....THERE IS A PROBLEM IN COLUMN (TOTAL_DEATH) AS IT IS NVARCHAR(255),SO THE ORDER BY IS NOT ACCURATE..**
**THE SOLUTION IS CASTING THE TOTAL_DEATH COLUMN INTO INT**:
```sql
select location,population,max(cast(total_deaths as bigint)) as [Number Of Death]
from Covid_Deaths
group by location,population
order by [Number Of Death] desc;
```

5.**Show which month has most number of Infections**:
```sql
select month(date) as Months ,sum(new_cases) as Total_new_cases_per_month from Covid_Deaths
group by month(date)
order by month(date) desc
```

6. **Show which month has more number of deaths**:
```sql
select month(date) as Months ,sum(convert(int,new_deaths)) as Total_new_deaths_per_month from Covid_Deaths
group by month(date)
order by month(date) desc
```
**NOTEEEE ➡➡➡➡➡ By Analyzing....december has most number of Infections and deaths**


7. **Show which Year has most number of Infections**:
```sql
select year(date) as Years ,sum(convert(int,new_cases)) as Total_new_cases_per_year from Covid_Deaths
group by year(date)
order by Total_new_cases_per_year desc
```

8. **Show which Year has most number of deaths**:
```sql
select year(date) as Years ,sum(convert(int,new_deaths)) as Total_new_deaths_per_year from Covid_Deaths
group by year(date)
order by Total_new_deaths_per_year desc

```
**NOTEEEE ➡➡➡➡➡ By Analyzing... 2020 has most number of Infections and deaths....Things got better in 2021**

9. **let's see which continent  has the highest number of death**:
```sql
select continent,max(cast(total_deaths as int)) AS [Number of Death]
from Covid_Deaths
group by continent
order by [Number of Death] desc;

```

10. **which dayyy Has the Highest Infection cases**:
```sql
select date,sum(new_cases) as [Total new cases] ,sum(cast(new_deaths as int)) as [Total New Deaths]
from Covid_Deaths
group by date
order by [Total new cases] desc;
```

11.**Show persentage of new death over new cases per day**

```sql
--Handling Dividing By Zero In Two Methods
--1.using Case When:

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
```

11. **SHow world new cases and new deaths**
``` sql
select 
sum(new_cases) as [Total New Cases],
sum(CAST(new_deaths as Int)) AS [Total New Deaths],
(sum(CAST(new_deaths as Int))/nullif(sum(new_cases),0))*100  AS [Division new deaths to new cases]
from Covid_Deaths
where continent is not null
order by 1;
```


12.**join covid vaccinations and covid deaths tables**
**...I join two tables continuously. SO Let's do CTE(Common Table Expression)**
```sql
with covid_deaths_Vaccinations AS(
select cd.continent,cd.location,cd.date,cd.population,cd.new_cases,cd.new_deaths,
cv.new_vaccinations,cv.total_vaccinations,cv.people_vaccinated 
from Covid_Deaths cd join 
Covid_Vaccinations cv 
on cd.location = cv.location
and cd.date = cv.date)

SELECT *
FROM covid_deaths_Vaccinations;
```

13.**look at the total population vs new_vaccination for every day**
```sql
select cd.location,cd.date,population,cv.new_vaccinations from Covid_Deaths cd
join Covid_Vaccinations cv
on cd.location = cv.location
and cd.date = cv.date
order by location,date;
```

14.**view total new_Vacination in each country..Using Aggregation Function**
```sql
--I will use the CTE (covid_deaths_Vaccinations) I created previously:

select location,sum(convert(int,new_vaccinations)) AS [Total New vaccinations] 
from covid_deaths_Vaccinations
group by location
order by [Total New vaccinations] desc;

```

**Alter new_vaccinations column into int instead of nvarchar to do aggregation functions easier.**

```sql
ALTER TABLE Covid_Vaccinations ALTER COLUMN new_vaccinations INT;
```

15.**view total new_Vacination in each country..Using WIndowing Fucntion (ROLLING COUNT)**
```sql
select continent,location,
date,population,new_vaccinations,
sum(new_vaccinations) over(partition by location order by location,date ) AS [Total vaccinations (Rolling Count)]
from covid_deaths_Vaccinations;

```
16.**Divide Max Rolling Count by population to know how much persentage per country got Vaccinated**
```sql
--Using SubQuery:

select location,(max([total new vaccinations ])/population)*100 as [Vaccinated Persentage] from (
select continent,location,date,population,new_vaccinations,
sum(new_vaccinations) over(partition by location order by location, date) as [total new vaccinations ]
from covid_deaths_Vaccinations )t
group by population,location
order by [Vaccinated Persentage] desc

```

17.**AS Number of Population Across The World Wide is Important so we're gonna put it in a View**
```sql
create view TotalPopulation AS
select sum([Population per county]) AS [Total Population]
from (
    SELECT location, max(population) AS [Population per county]
    from Covid_Deaths
    group by location
) t;

select * from TotalPopulationView;
```


**Convert people_vaccinated from nvarchar to bigint.**
```sql
alter table Covid_Vaccinations alter column people_vaccinated  bigint;
```


18.**Show persentage of people got vaccinated in each country**
```sql
select location,round(max([Total People vaccinated per country]/population)*100,1) as [Vaccinated people per country]
from (
	  select location,date,population,
	  max(people_vaccinated) over(partition by location) as [Total People vaccinated per country]
	  FROM covid_deaths_Vaccinations)t
group by location
order by [Vaccinated people per country] desc
```

19.**put total people vaccinated in world wide in a VIEW**
```sql
create view totalpeople_vaccinated AS
select sum([total people vaccinated per country]) as [total people vaccinated in world wide]
from(
        select location,
        	  max(people_vaccinated) as [total people vaccinated per country]
        	  FROM covid_Vaccinations
        	  group by location
        	  )t


select * from totalpeople_vaccinated; 

```

20.**Compare world wide population and world wide people vaccinated**
```sql
SELECT
    (SELECT * FROM totalpeople_vaccinated) AS [total people vaccinated in WW],
    (SELECT * FROM TotalPopulation) AS [Total Population in WW];
```

21.**FINALLYYY: What percentage of people in the world are vaccinated? (COMBINE BOTH VIEWS)**
```sql
  select
    round(((SELECT * FROM totalpeople_vaccinated)/(SELECT * FROM TotalPopulation))*100,1) as [percentage of people in the world are vaccinated]
```
**NOTEEE ➡➡➡➡➡ only 7.7% of the population was vaccinated by 2021**


## Findings

-**Infection and Vaccination Trends**: Identified that only 7.7% of the global population had been vaccinated by 2021, while tracking infection trends revealed the months with the highest number of COVID-19 cases and deaths.                                                                                                     
-**Global Impact Analysis**: Highlighted countries with the highest infection and death rates relative to their populations, alongside determining the continents most affected by COVID-19 fatalities.
-**Population Infection Rates**: Calculated the percentage of the population infected over time, providing insights into the progression and intensity of the pandemic across different regions.
-**Temporal Insights**: Leveraged date functions to uncover yearly and monthly trends, revealing critical periods of heightened infections and fatalities to support targeted interventions.

## Reports

-**Infection and Mortality Analysis Report**: Detailed insights on total COVID-19 cases and deaths globally, broken down by countries, continents, and months, highlighting regions with the highest infection and mortality rates relative to their populations.
-**Vaccination Progress Report**: Comprehensive data showing vaccination rates across countries and continents, including trends over time and insights into the percentage of the population vaccinated by 2021.
-**Trend and Forecast Report**: Analysis of infection and death patterns over time, identifying months with the highest activity and offering cumulative rolling counts to understand pandemic progression and predict future hotspots.

## Conclusion

This project provides critical insights that can help governments and healthcare organizations make informed decisions to allocate resources effectively, implement targeted interventions, and develop strategies to mitigate the impact of future pandemics.


## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.


