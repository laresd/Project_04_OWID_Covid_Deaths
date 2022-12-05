# Data Exploration & Dashboard: OWID - Covid Deaths (Excel, SQL, Tableau)

## Table of Contents

- [Summary](README.md#summary)
- [Part 1: Data Exploration](README.md#part-1-data-exploration)
- [Part 2: Data Visualization](README.md#part-2-data-visualization)
- [References](README.md#references)
- [Screenshot](README.md#screenshot)

## Summary

In this project, I'll be working with the [Coronavirus (COVID-19) Deaths dataset](https://ourworldindata.org/covid-deaths) from Our World In Data (OWID), which contains data on the number of confirmed deaths from COVID-19 worldwide.

This project is divided into two parts. In the first part, I'll do some data exploration using Excel and SQL in **Microsoft SQL Server Management Studio (SSMS)**, and in the second part, I'll then visualize the data in **Tableau Public** by creating a dashboard.

## Part 1: Data Exploration

The data exploration part includes multiple steps:

- Download the dataset as CSV file and open it in Excel.
- Prepare the dataset by rearranging necessary table columns and deleting unnecessary ones.
- Create two tables and save them as CovidDeaths.xlsx and CovidVaccinations.xlsx.
- Create a new database in SSMS named *PortfolioProject*.
- Open the Excel sheets in SSMS to import the data into the *PortfolioProject* database.
- Create multiple SQL queries to explore the data and save them to [OWID_Covid_Deaths.sql](https://github.com/laresd/Project_04_OWID_Covid_Deaths/blob/main/OWID_Covid_Deaths.sql).

```SQL
-- This is one of the SQL queries I did during the data exploration process.

-- Creating a "rolling count" of new vaccinations by using a Common Table Expression (CTE) named PopvsVac.
-- A CTE is needed here, because you can't use a column that you've just created and use it in the next one, here RollingPeopleVaccinated.
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
-- Create a "rolling count" of new vaccinations by using a SUM function and a PARTITION BY clause.
-- Break the locations up by using a PARTITION BY clause, so that every time you get to a new location, the aggregate function starts over.
-- CAST and CONVERT do basically the same.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100 -- This can't be calculated here, but in the next SELECT clause.
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> '' OR dea.continent <> NULL
--ORDER BY 2, 3 -- No need for ordering here.
)
SELECT *, (RollingPeopleVaccinated / population) * 100 -- Calculate the percentage of people vaccinated relative to the total population.
FROM PopvsVac
```

### A Quick Note on Converting Data Types in SQL

During the data exploration process it was necessary for some SQL queries to convert the expressions from one data type to another. For this I used the CAST function in some places and the CONVERT function in others, as both functions can be used for the conversion of data types.

```SQL
-- This code converts the values in the new_vaccinations column to the float data type.

-- Using CAST:
CAST(new_vaccinations AS float)

-- Using CONVERT:
CONVERT(float, new_vaccinations)
```

## Part 2: Data Visualization

Before the data can be visualized in Tableau, it is necessary to save the tables from the SQL queries to Excel files. The reason for this is that Tableau Public currently doesn't support the direct import of SQL files.

- Save the tables from the SQL queries to separate Excel files named [Tableau_Table_1.xlsx](https://github.com/laresd/Project_04_OWID_Covid_Deaths/blob/main/Tableau_Table_1.xlsx), [Tableau_Table_2.xlsx](https://github.com/laresd/Project_04_OWID_Covid_Deaths/blob/main/Tableau_Table_2.xlsx), [Tableau_Table_3.xlsx](https://github.com/laresd/Project_04_OWID_Covid_Deaths/blob/main/Tableau_Table_3.xlsx), and [Tableau_Table_4.xlsx](https://github.com/laresd/Project_04_OWID_Covid_Deaths/blob/main/Tableau_Table_4.xlsx).
- Open each Excel file in Tableau to import the data.
- Create the data visualizations.
- Finally, create the dashboard and upload it to [Tableau Public](https://public.tableau.com/app/profile/larsdataviz/viz/OWIDCovidDeaths/Dashboard1).

### A Quick Note on Formatting Cell Values in Excel

In the German version of Excel, the values in the *date* column (2022-11-18 00:00:00.000) cannot be converted to dates (18.11.2022) by changing the format, but remain text strings. At least it didn't work for me.

![Tableau_Table_4_2x](https://user-images.githubusercontent.com/53877625/205499714-2ad52b03-045b-443a-b102-73acbe019d82.png)

I solved this problem by creating a new *date* column and using an Excel formula (see below). This formula extracts the necessary values from the original *date* column and inserts them into the new one.

After that, I copied the entire cells in the new *date* column and pasted it as values in the same place. By doing this, the table cells in the new *date* column now only contain the date value and not the formula with references to the original *date* column. Afterwards, I deleted the original *date* column, as it was no longer needed.

```
-- This Excel formula extracts the day, month, and year values from the original date column and inserts them into the new one.
-- This returns a date value like 18.11.2022.

-- In German version of Excel:
=DATWERT(VERKETTEN(TEIL(C2;9;2);".";TEIL(C2;6;2);".";LINKS(C2;4)))

-- In English version of Excel:
=DATEVALUE(CONCAT(MID(C2,9,2),".",MID(C2,6,2),".",LEFT(C2,4)))
```

## References

- [Coronavirus (COVID-19) Deaths Dataset by Our World In Data (OWID)](https://ourworldindata.org/covid-deaths)
- [OWID Covid Death SQL Queries](https://github.com/laresd/Project_04_OWID_Covid_Deaths/blob/main/OWID_Covid_Deaths.sql)
- [Finished Dashboard on Tableau Public](https://public.tableau.com/app/profile/larsdataviz/viz/OWIDCovidDeaths/Dashboard1)

## Screenshot

![Project_04](https://user-images.githubusercontent.com/53877625/205499801-b93c1d1c-ca11-47f1-8a7e-0e7ccabf9ce6.png)
