Select *
From Covid19_Project.dbo.Covid19_Deaths
Where continent is not null
Order by 3,4

Select location, total_tests, new_tests, total_vaccinations, ((cast (total_tests as numeric))/(cast (total_tests as numeric)))*100 as VaccinationPercentage
From Covid19_Project.dbo.Covid19_Vaccinations
Where continent is not null
Order by 3,4

--Let's get to work.

Select continent, location, date, population, total_cases, new_cases, total_deaths
From Covid19_Project.dbo.Covid19_Deaths
Order by 2,3,4


--Show Total_cases Vs Total_Deaths
-- Shows the propability of dying when you contacted Covid in you country

Select continent, location, date, population, total_cases, new_cases, total_deaths, ((cast (total_deaths AS numeric))/(cast (total_cases AS numeric)))*100 As DeathPercentage
From Covid19_Project.dbo.Covid19_Deaths
Order by 2,3,4

-- Shows the propability of dying when you contacted Covid in you United State

Select continent, location, date, population, total_cases, new_cases, total_deaths, ((cast (total_deaths AS numeric))/(cast (total_cases AS numeric)))*100 As DeathPercentage
From Covid19_Project.dbo.Covid19_Deaths
Where location like '%state%'
Order by 1,2

-- Shows the percentage of people who got Covid in United State

Select continent, location, date, population, total_cases, ((cast (total_cases AS numeric))/population)*100 As InfectionPercentage
From Covid19_Project.dbo.Covid19_Deaths
Where location like '%state%'
Order by 1,2

-- Shows the Counrty with the Highest Infection rate

Select location, population, Max (cast (total_cases as numeric)) as HighestInfectedCount, ((cast (total_cases AS numeric))/population)*100 As InfectionPercentages
From Covid19_Project.dbo.Covid19_Deaths
Where continent is not null
Group by location, population,  total_cases
Order by InfectionPercentages desc


-- Shows the Counrty with the Highest Deaths count

Select location, population, Max (cast (total_deaths As numeric)) as TotalDeathCount
From Covid19_Project.dbo.Covid19_Deaths
Where continent is not null
Group by location, population
Order by TotalDeathCount desc


-- Shows the Continent with the Highest Deaths count  (where continent is not null)


Select continent, Max (cast (total_deaths As numeric)) as TotalDeathCount
From Covid19_Project.dbo.Covid19_Deaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Shows the Continent with the Highest Deaths count (where continent is null)

Select location, Max (cast (total_deaths As numeric)) as TotalDeathCount
From Covid19_Project.dbo.Covid19_Deaths
Where continent is null
Group by location
Order by TotalDeathCount desc


-- Shows the Country with the Highest Deaths count per population

Select location, population, Max (cast (total_deaths As numeric)) as TotalDeathCount, ((Max (cast (total_deaths As numeric)))/population)*100 as TotalDeathCount_Percentage
From Covid19_Project.dbo.Covid19_Deaths
Where continent is not null
Group by location, population
Order by location, TotalDeathCount_Percentage desc


--Global Numbers 

Select  date, sum (new_cases) as Total_Cases, Sum (new_deaths) as Total_Deaths,isnull ((Sum (new_deaths)/(nullif (sum (new_cases),0))),0)*100 as DeathPercentage
From Covid19_Project.dbo.Covid19_Deaths
Where continent is not null
Group By date
Order by 1,2


-- Shows the total cases, total deaths and Deaths Percentages
Select sum (new_cases) as Total_Cases, Sum (new_deaths) as Total_Deaths,isnull ((Sum (new_deaths)/(nullif (sum (new_cases),0))),0)*100 as DeathPercentage
From Covid19_Project.dbo.Covid19_Deaths
Where continent is not null
--Group By date
Order by 1


-- Shows the world population, total cases, total deaths and Deaths Percentages
Select sum (population) as WorldPopulation, sum (new_cases) as Total_Cases, Sum (new_deaths) as Total_Deaths,isnull ((Sum (new_deaths)/(nullif (sum (new_cases),0))),0)*100 as DeathPercentage
From Covid19_Project.dbo.Covid19_Deaths
Where continent is not null
Order by 1



-- Let Join the two tables

Select *
From Covid19_Project..Covid19_Deaths  CD
Join Covid19_Project..Covid19_Vaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
Order By 2,3


-- Shows the population vs Total Vaccination
Select CD.continent, CD.location, CD.date, CD.population, CV.total_vaccinations
From Covid19_Project..Covid19_Deaths  CD
Join Covid19_Project..Covid19_Vaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
Order By 2,3


-- Shows the population vs Total Vaccination
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum (cast (Cv.new_vaccinations as numeric)) over (partition By Cd.location order by CD.date) as RollingNewVaccCount
From Covid19_Project..Covid19_Deaths  CD
Join Covid19_Project..Covid19_Vaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
and CV.new_vaccinations is not null
Order By 2,3



-- Shows the population, Vaccination and PercentPopulationVaccinat
-- Here are going to use Two option to Solve PercentPopulationVaccinat, because our calculation will need an aggregate funtion "RollingNewVaccCount".

-- First Option Is CTE

--CTE

With PercentPopulationVaccinated ( continent, Location, Date, Population, New_Vaccinations, RollingNewVaccCount)
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum (cast (Cv.new_vaccinations as numeric)) over (partition By Cd.location order by CD.date) as RollingNewVaccCount
From Covid19_Project..Covid19_Deaths  CD
Join Covid19_Project..Covid19_Vaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
and CV.new_vaccinations is not null
--Order By 2,3
)

Select *, (RollingNewVaccCount/population)*100 as PercentPopulationVaccinat
From PercentPopulationVaccinated


-- Second Option Is Temp Table

--Temp Table

Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingNewVaccCount numeric
)

Insert Into #PercentPopulationVaccinated 
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum (cast (Cv.new_vaccinations as numeric)) over (partition By Cd.location order by CD.date) as RollingNewVaccCount
From Covid19_Project..Covid19_Deaths  CD
Join Covid19_Project..Covid19_Vaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
and CV.new_vaccinations is not null
--Order By 2,3


Select *, (RollingNewVaccCount/population)*100 as PercentPopulationVaccinat
From #PercentPopulationVaccinated


-- Now, Let's create View for later Visualization

Create View PercentPopulationVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum (cast (Cv.new_vaccinations as numeric)) over (partition By Cd.location order by CD.date) as RollingNewVaccCount
From Covid19_Project..Covid19_Deaths  CD
Join Covid19_Project..Covid19_Vaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
and CV.new_vaccinations is not null

Select *
From PercentPopulationVaccinated