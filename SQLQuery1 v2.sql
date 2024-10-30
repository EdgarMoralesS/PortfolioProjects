--Select *
--From PortfolioProject1..CovidDeaths
--order by 3,4

Select *
From PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4


--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4

-- Select the Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2

-- Ahora vamos a hacer el total de casos vs el total de muertes por covid alv , por lo que vamos a dividir el total de muertes entre el total de casos vdd
-- Esto nos da el porcentaje de muerte si contraes el covicho en estados unidos 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PorcentajeMuerte
From PortfolioProject1..CovidDeaths
where date like '%2021%'
order by 1,2

-- Muestra el porcentaje de casos covid comparado con el total de poblacion... 

Select Location, date, total_cases, total_deaths, (total_cases/population)*100 as PorcentajeCasos
From PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2

-- Lets look at the highest infection rate compared to population. To do so, if we run this query WE GET AN ERROR
Select Location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)*100) as PorcentajeCasos
From PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2

-- THIS is because we are ussing an aggregate or groupby ... so...

Select Location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)*100) as PorcentajeCasos
From PortfolioProject1..CovidDeaths
Group by Location, population
order by PorcentajeCasos desc


-- Now lets see the highest Death Count Populaion, now there is a problem in the numbers , if you run these

Select Location, population, MAX(total_deaths) as TotalDeaths,  Max((total_deaths/population)*100) as PorcentajeCasos
From PortfolioProject1..CovidDeaths
Group by Location, population
order by TotalDeaths desc
 

 -- IT will not show the correct data, usemos int, now lets add the where continent is not null to actually only see countries.

 Select Location, population, MAX(cast(total_deaths as int)) as TotalDeaths,  Max((total_deaths/population)*100) as PorcentajeCasos
From PortfolioProject1..CovidDeaths
where continent is not null
Group by Location, population
order by TotalDeaths desc
 
-- LETS BREAK THINGS DOWN, con el problema
Select continent, MAX(cast(total_deaths as int)) as TotalDeaths,  Max((total_deaths/population)*100) as PorcentajeCasos
From PortfolioProject1..CovidDeaths
where continent is not null
Group by continent
order by TotalDeaths desc

-- tiene el problema de que solo esta usando el maximo de cada uno... lo cual tiene sentido, veamos si puedo agregar un sum...
Select  continent, location, max(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject1..CovidDeaths
where continent is not null
group by continent, location
order by TotalDeaths desc


-- okay seguire con el tuto JAJAJ, like okay, puedo hacer una suma de los maximos de cada uno creo, pero no se como si jsjsjs

 Select location, MAX(cast(total_deaths as int)) as TotalDeaths,  Max((total_deaths/population)*100) as PorcentajeCasos
From PortfolioProject1..CovidDeaths
where continent is null
Group by location
order by TotalDeaths desc

--

SELECT 
    continent, 
    SUM(CAST(total_deaths AS INT)) AS TotalDeaths
FROM 
    PortfolioProject1..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeaths DESC;

-- GPT hizo esto

WITH LatestDeaths AS (
    SELECT 
        continent, 
        location, 
        MAX(date) AS LatestDate
    FROM 
        PortfolioProject1..CovidDeaths
    WHERE 
        continent IS NOT NULL
    GROUP BY 
        continent, location
)
SELECT 
    cd.continent, 
    SUM(CAST(cd.total_deaths AS INT)) AS TotalDeaths
FROM 
    PortfolioProject1..CovidDeaths cd
JOIN 
    LatestDeaths ld
    ON cd.continent = ld.continent 
    AND cd.location = ld.location 
    AND cd.date = ld.LatestDate
GROUP BY 
    cd.continent
ORDER BY 
    TotalDeaths DESC;
-- Pues si , es correcto este pedo jaja

/* 
Explicación:
CTE LatestDeaths: Esta es una tabla temporal (Common Table Expression) que obtiene la fecha más reciente (MAX(date)) para cada locación dentro de cada continente.
JOIN: Unimos la tabla original CovidDeaths con la tabla temporal LatestDeaths para obtener solo los registros correspondientes a la última fecha de cada locación.
SUM(CAST(cd.total_deaths AS INT)): Una vez que tenemos los datos correspondientes a la última fecha de cada locación, sumamos los valores de muertes por continente.
GROUP BY cd.continent: Agrupamos por continente para obtener el total por cada uno.
Esto te dará el total de muertes por continente utilizando solo los datos más recientes de cada locación.
*/

--
 Select location, MAX(CAST(total_deaths AS int)) as TOTALMUERTES
From PortfolioProject1..CovidDeaths
where continent is null
Group by location
order by TOTALMUERTES desc

--Showing the continents with the highest death count per population
--

Select continent, MAX(CAST(total_deaths AS int)) as TOTALMUERTES
From PortfolioProject1..CovidDeaths
where continent is not null
Group by continent
order by TOTALMUERTES desc

-- Este yo pero yo lo hice mal jaja, deja veo como arreglar esto si.
Select continent,MAX(population) as Population, MAX(CAST(total_deaths AS int)) as TOTALMUERTES ,  MAX(CAST(total_deaths AS int))/MAX(population)*100 as DeathPerP
From PortfolioProject1..CovidDeaths
where continent is not null
Group by continent

-- 
Select location,MAX(population) as Population, MAX(CAST(total_deaths AS int)) as TOTALMUERTES ,  MAX(CAST(total_deaths AS int))/MAX(population)*100 as DeathPerP
From PortfolioProject1..CovidDeaths
where continent is  null
Group by location
order by TOTALMUERTES desc

-- GLOBAL NUMBERS

Select  date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2

Select  date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null
Group By date
order by 1,2


-- Juntemos dos tablas , esto con un Join , tomando la locacion y la fecha.

Select *
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinations, this will give the continent, location, date and population from deaths and the new vaccinated from vac, 
-- previously we had the columns matched, location and date, so now we are looking at the new vacc

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-- Now we add per Location, but , the new vacc we are goint to sum them and order them by Location and DATE, wich will give us a Sum per Day and not just the
--Total of vacc per location each time


-- Aqui estoy probando si me puedo evitar hacer una tabla temporal para hacer un calculo de una columna... haciendo todo el calculo de nuevo desde cero jaja lo cual
-- no tiene mucho sentido pero queria saber si se podia si.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated , SUM(Convert(int,vac.new_vaccinations)/Population *100) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as NewRolling
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Ahora, si queremos hacer alguna operacion con esa columna que acabamos de crear, vamos a necesitar usar alguna forma de tabla temporal.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations ,RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *
From PopvsVac

-- Ahora si podemos hacer calculos con la nueva columna creada. (CTE)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations ,RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Otra tabla que nos permite usar una columna y despues hacer operaciones en la misma.

-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated
