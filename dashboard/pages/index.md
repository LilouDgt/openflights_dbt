---
title: ✈️ OpenFlights Data Pipeline
---

This dashboard monitors the integrity and insights of the OpenFlights dataset, processed via **dbt** and **DuckDB**.

<BigValue 
  data={route_kpis} 
  value=total_routes
  title="# Total Routes"
/>

<BigValue 
  data={route_kpis} 
  value=active_airlines
  title="Active Airlines"
/>
<BigValue 
  data={route_kpis} 
  value=international_routes
  title="# International Routes"
/>
<BigValue 
  data={route_kpis} 
  value=domestic_routes
  title="# Domestic Routes"
/>

```sql route_kpis
select 
    count(*) as total_routes,
    count(distinct airline_name) as active_airlines,
    sum(case when is_international then 1 else 0 end) as international_routes,
    sum(case when is_international = false then 1 else 0 end) as domestic_routes
from openflights.fct_routes
```

```sql hub_distribution
select 
    airport_category, 
    count(*) as airport_count 
from openflights.dim_airport_hubs 
group by 1 
order by 2 desc
```

<BarChart
data={hub_distribution}
x=airport_category
y=airport_count
title="Global Air Infrastructure by Category"
fillColor="#2ecc71"
/>

```sql top_performers
select 
    airport_name, 
    city, 
    country, 
    total_routes_supported 
from openflights.dim_airport_hubs 
where airport_category = 'Global Hub'
order by total_routes_supported desc 
limit 10
```

### Top 10 Airports 
<DataTable data={top_performers}>
<Column id=airport_name label="Global Hub Name"/>
<Column id=total_routes_supported label="Routes" align=right/>
</DataTable>

### Global Connectivity Map
Each bubble represents an airport; size indicates the number of outgoing routes.

<BubbleMap 
    data={map_data} 
    lat=latitude 
    long=longitude 
    size=total_routes_supported
    value=country
    pointSize=2
    pointName=airport_name
    title="Bubble Map"
/>

```sql map_data
select * from openflights.dim_airport_hubs
where total_routes_supported > 450
```

```sql top_airlines
select 
    airline_name, 
    count(*) as route_count
from openflights.fct_routes
group by 1
order by 2 desc
limit 10
```

<DataTable data={top_airlines}>
<Column id=airline_name label="Airline"/>
<Column id=route_count label="Total Routes" fmt="#,##0"/>
</DataTable>

