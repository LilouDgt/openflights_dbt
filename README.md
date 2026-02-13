# ✈️ OpenFlights End-to-End Analytics Project

This project demonstrates a full-cycle analytics engineering workflow using **dbt** and **DuckDB**. I transformed raw aviation data from the OpenFlights dataset into a clean, tested, and documented star schema ready for analysis.

## 🎯 Project Objective
To build a robust data pipeline that handles common real-world data issues (missing values, type mismatches, and orphan records) and provides a "source of truth" for flight route analytics.

## 🛠️ Tech Stack
- **Data Engine:** [DuckDB](https://duckdb.org/) (Fast, local analytical database)
- **Transformation:** [dbt-core](https://www.getdbt.com/)
- **Testing:** dbt-tests & [dbt-expectations](https://github.com/calogica/dbt-expectations)
- **Language:** SQL & Python (Pandas for initial exploration)

## 🏗️ Data Architecture

### 1. Staging Layer (`stg_`)
* Initial cleanup of raw CSV data.
* Used `TRY_CAST` and `CASE` statements to handle legacy null strings like `\N`.
* Standardized naming conventions across all sources.

### 2. Marts Layer (`dim_` & `fct_`)
* **dim_airports**: Master list of airports with validated latitude/longitude coordinates.
* **dim_airlines**: Verified list of active airlines.
* **fct_routes**: A centralized fact table connecting routes to airports and airlines. I utilized **Inner Joins** to ensure strict referential integrity.

## 🧩 Challenges & Solutions

### 🛑 The `\N` String Problem
**Issue:** The source data used the literal string `\N` to represent null values, causing calculation and join errors.  
**Solution:** Implemented `try_cast(column as integer)` logic in the staging layer to safely convert these strings into true SQL `NULL` values.

### 🔗 Referential Integrity
**Issue:** Several thousand routes referenced airport IDs that did not exist in the airports master list.  
**Solution:** Used dbt `relationships` tests to identify orphans and applied filtering in the Marts layer to ensure only valid, traceable routes are included in the final data.

## 🧪 Data Quality Tests
I implemented a multi-layered testing strategy:
- **Schema Tests:** `unique` and `not_null` on primary keys.
- **Relationship Tests:** Ensured every route maps to a valid airport and airline.
- **Value Constraints:** Used `dbt-expectations` to ensure:
  - Latitude is between `-90` and `90`.
  - Longitude is between `-180` and `180`.
  - Column types are strictly enforced as `integers`.

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
