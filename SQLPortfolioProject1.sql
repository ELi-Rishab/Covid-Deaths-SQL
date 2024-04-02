Select * 
From CovidDeaths$
Order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths$
Order BY 1,2

--Death percentages in India

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%india%'
Order BY 1,2

-- What percentage of population got covid in INDIA
Select location,date,population,total_cases,(total_cases/population)*100 AS CovidPopulation
From PortfolioProject..CovidDeaths$
where location like '%india%'
Order BY 1,2

-- Highest infection rate by country per population
Select location,population,MAX(Total_cases) AS HighestInfectionCount,max((total_cases/population))*100 AS PercetangePopulationInfected
From PortfolioProject..CovidDeaths$
GROUP BY Location, population
Order BY PercetangePopulationInfected desc

-- Highest Death rate by country per population 'Removed Continents'
Select location,population,MAX(cast(total_deaths as int)) AS DeathCount
From PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location,population
Order BY DeathCount desc

-- Highest Death rate by Continents
Select location,population,MAX(cast(total_deaths as int)) AS DeathCount
From PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY continent,population,location	
Order BY DeathCount desc

--Global Sum Of Death By per day
Select date,Sum(new_cases) AS Casesum,
Sum(Cast(new_deaths as int))AS DeathSum,
Sum(Cast(new_deaths as int))/Sum(new_cases) As DeathPercentageSum
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
Order BY 1,2

--Total Global percentage Of Deathsum and percentage
Select Sum(new_cases) AS Casesum,
Sum(Cast(new_deaths as int))AS DeathSum,
Sum(Cast(new_deaths as int))/Sum(new_cases) As DeathPercentageSum
From PortfolioProject..CovidDeaths$
where continent is not null
Order BY 1,2


-- Total Population Vs Vaccination uing CTE
With Vac_vs_Pop(Continent,location,Date,Population,new_vaccinations,vacpeople)as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location ,dea.date) AS vacpeople
From PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccination$ AS vac
	on dea.location = vac.location 
	AND dea.date=vac.date
where dea.continent is not null 

)
Select *,(vacpeople/Population)*100
FROM Vac_vs_Pop

-- Total Population Vs Vaccination uing Temp Tables
Create Table #Percenpopvac
(
Continent Varchar(255),
Location Varchar(255),
Date datetime,
Population Numeric,
New_Vaccination Numeric,
Vacpeople Numeric,
peoplevacinated Numeric
)
 Insert INTO #Percenpopvac
	Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location ,dea.date) AS vacpeople
	From PortfolioProject..CovidDeaths$ AS dea
	Join PortfolioProject..CovidVaccination$ AS vac
		on dea.location = vac.location 
		AND dea.date=vac.date
	where dea.continent is not null 