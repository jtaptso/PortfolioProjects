/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP(100)*
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  order by 3, 4

  --SELECT *
  --FROM [PortfolioProject].[dbo].[CovidVaccinations]
  --order by 3, 4

  SELECT  location, date, total_cases, new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  order by 1, 2

  --total cases versus total deaths
    SELECT  location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  order by 1, 2

    --Percentage of Population infected
  SELECT  location, date, total_cases, (CAST(total_cases as float)/CAST(population as float))*100 as PercentPopulationInfected
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  order by 1, 2


    --Countries with Highest infection Rate compared to Population
    SELECT  location, population, MAX(CAST(total_cases as float)) AS HighestInfectionCount,MAX(CAST(total_cases as float)/CAST(population as float))*100 as PercentPopulationInfected
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  group by location, population
  order by PercentPopulationInfected desc

  --Countries with highest Deaths count per popluation
  SELECT  location, MAX(CAST(total_deaths as float)) AS TotalDeathsCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  group by location
  order by TotalDeathsCount desc


  
  --Continent with highest Deaths count per popluation
  SELECT  location, MAX(CAST(total_deaths as float)) AS TotalDeathsCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is null
  group by location
  order by TotalDeathsCount desc

  
  --Continent with highest Deaths count per popluation
  SELECT  continent, MAX(CAST(total_deaths as float)) AS TotalDeathsCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  group by continent
  order by TotalDeathsCount desc



  --Continent with highest Deaths count per popluation
  SELECT  continent, MAX(CAST(total_deaths as float)) AS TotalDeathsCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  group by continent
  order by TotalDeathsCount desc


  --Global numbers per day
  SELECT  date, SUM(CAST(new_cases AS float)) AS total_cases, SUM(CAST(new_deaths AS float)) AS total_deaths, (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  group by date
  order by 1, 2  


  
  --Total
  SELECT  SUM(CAST(new_cases AS float)) AS total_cases, SUM(CAST(new_deaths AS float)) AS total_deaths, (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 as DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  where continent is not null
  --group by date
  order by 1, 2 

  --TOtal vaccination Vs Vaccination
  SELECT 
		dea.continent 
		,dea.location 
		,dea.date
		,dea.population 
		,vac.new_vaccinations 
		,SUM(CONVERT(float, vac.new_vaccinations )) OVER (PARTITION by dea.location order by dea.location, dea.date) AS RollingPeaopleVaccinated
  FROM CovidDeaths dea
  JOIN CovidVaccinations vac ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  --Use CTE
  WITH PopVsVac(continent, location, date, population, new_vaccinations, RollingPeaopleVaccinated)
  AS
  (
  SELECT 
		dea.continent 
		,dea.location 
		,dea.date
		,dea.population 
		,vac.new_vaccinations 
		,SUM(CONVERT(float, vac.new_vaccinations )) OVER (PARTITION by dea.location order by dea.location, dea.date) AS RollingPeaopleVaccinated
  FROM CovidDeaths dea
  JOIN CovidVaccinations vac ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null

  )
  SELECT*, (RollingPeaopleVaccinated/CAST(population as float))
  FROM PopVsVac


  -- TEMP TABLE
  DROP TABLE if exists #PercentPopulationVaccinated

  CREATE TABLE #PercentPopulationVaccinated
  (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeaopleVaccinated numeric
  )

  INSERT INTO #PercentPopulationVaccinated
  SELECT 
		dea.continent 
		,dea.location 
		,dea.date
		,dea.population 
		,vac.new_vaccinations 
		,SUM(CONVERT(float, vac.new_vaccinations )) OVER (PARTITION by dea.location order by dea.location, dea.date) AS RollingPeaopleVaccinated
  FROM CovidDeaths dea
  JOIN CovidVaccinations vac ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null

  SELECT*, (RollingPeaopleVaccinated/CAST(population as float))
  FROM #PercentPopulationVaccinated

-- Views to store data
CREATE View PercentPopulationVaccinated AS 
SELECT 
		dea.continent 
		,dea.location 
		,dea.date
		,dea.population 
		,vac.new_vaccinations 
		,SUM(CONVERT(float, vac.new_vaccinations )) OVER (PARTITION by dea.location order by dea.location, dea.date) AS RollingPeaopleVaccinated
  FROM CovidDeaths dea
  JOIN CovidVaccinations vac ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
