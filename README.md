# ✈️ OpenFlights Analytics Project

I created this project to show a full-cycle analytics engineering workflow using **dbt** and **DuckDB**. I transformed raw data from the OpenFlights dataset into a clean, tested, and documented star schema ready for analysis.

## 🎯 Project Objective
My goal is to build a data pipeline that handles common real-world data issues (missing values, type mismatches, and orphan records) and provides a dashboard for flight route analytics.

## 🛠️ Tech Stack
- **Database:** [DuckDB](https://duckdb.org/) (Fast, local analytical database)
- **Data Transformation:** [dbt-core](https://www.getdbt.com/)
- **Testing:** dbt-tests & [dbt-expectations](https://github.com/calogica/dbt-expectations)
- **Language:** SQL & Python (Pandas for initial exploration)

## 🏗️ Data Architecture

### 1. Staging Layer (`stg_`)
* Initial cleanup of raw CSV data.
* Used `TRY_CAST` and `CASE` statements to handle strings like `\N`.
* Standardized naming conventions across all sources.

### 2. Marts Layer (`dim_` & `fct_`)
* **dim_airports**: List of airports with validated latitude/longitude coordinates.
* **dim_airlines**: List of active airlines.
* **fct_routes**: Dact table connecting routes to airports and airlines. I used **Inner Joins** to ensure referential integrity.

## 🧩 Challenges & Solutions

### 🛑 The `\N` String Problem
**Issue:** The source data used the string `\N` to represent null values, which caused calculation and join errors.  
**Solution:** Implemented `try_cast(column as integer)` logic in the staging layer to safely convert these strings into true SQL `NULL` values.

### 🔗 Referential Integrity
**Issue:** Several thousand routes referenced airport IDs that did not exist in the airports list.  
**Solution:** Used dbt `relationships` tests to identify orphans and applied filtering in the Marts layer to ensure only valid routes are included in the final data table.

## 🧪 Data Quality Tests
I implemented a multi-layered testing strategy:
- **Schema Tests:** `unique` and `not_null` on primary keys.
- **Relationship Tests:** Ensured every route maps to a valid airport and airline.
- **Value Constraints:** Used `dbt-expectations` to ensure:
  - Latitude is between `-90` and `90`. 
  - Longitude is between `-180` and `180`. (filter out coordinates outside of standard geographic bounds)
  - ID column types are strictly enforced as `integers`. 

## dbt Documentation

This project includes full dbt model and column documentation.

To explore lineage and metadata:

```
dbt docs generate
dbt docs serve
```

This opens an interactive documentation site with:

* model descriptions
* column definitions
* data tests
* lineage graph
