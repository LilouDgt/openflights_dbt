---
title: ✈️ OpenFlights Data Pipeline
---

This dashboard monitors the integrity and insights of the OpenFlights dataset, processed via **dbt** and **DuckDB**.

```sql countries
select distinct country from openflights.dim_airport_hubs group by 1 order by 1
```

<Dropdown
    name="selected_country"
    data={countries}
    value=country
    multiple=true
    selectAll=true
/>

## 📊 Network Overview
 
A snapshot of air traffic for the selected regions

<Grid cols=4>
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
</Grid>

```sql route_kpis
select 
    count(*) as total_routes,
    count(distinct airline_name) as active_airlines,
    sum(case when is_international then 1 else 0 end) as international_routes,
    sum(case when is_international = false then 1 else 0 end) as domestic_routes,
    sum(case when is_international then 1.0 else 0 end) / count(*) as international_ratio
from openflights.fct_routes
where country_of_origin in ${inputs.selected_country.value}
```



Currently, <Value data={route_kpis} column=international_routes/> routes are international. 
This represents <Value data={route_kpis} column=international_ratio fmt='pct1'/> of all air traffic for the selected region.

--- 
## 🏗️ Infrastructure & Geography
 
Airport distribution by category and geographic footprint across the selected region.

```sql hub_distribution
select 
    airport_category, 
    count(*) as airport_count 
from openflights.dim_airport_hubs 
where country in ${inputs.selected_country.value} and airport_category not in ('Private/Inactive')
group by 1 
order by 2 desc
```

```sql top_performers
select 
    airport_name, 
    city, 
    country, 
    total_routes_supported 
from openflights.dim_airport_hubs 
where country in ${inputs.selected_country.value}
qualify rank() over(order by total_routes_supported desc) <= 20
order by total_routes_supported desc 
limit 15
```
<Grid cols=2>
<BarChart
data={hub_distribution}
x=airport_category
y=airport_count
title="Air Infrastructure by Category"
swapXY=false
chartAreaHeight=300
xLabelRotation=30
fillColor="#2e65cc"
/>

<BubbleMap 
    data={map_data} 
    lat=latitude 
    long=longitude 
    size=total_routes_supported
    value=country
    pointSize=2
    pointName=airport_name
    title="Bubble Map"
    emptySet=pass 
    emptyMessage="No data found for this selection"
/>
</Grid>

---
 
## 🏆 Top Performers
 
The busiest airports and airlines by route count in the selected region.


<Grid cols=2>

<DataTable data={top_performers}>
<Column id=airport_name label="Global Hub Name" align=left />
<Column id=total_routes_supported label="Routes" title="Total Routes" align=left contentType=bar/>
</DataTable>


<ECharts config={
    {
        tooltip: {
            formatter: '{b}: {c} routes)'
        },
        title: {
            text: 'Top Airlines'
        },
        series: [
            {
                type: 'treemap',
                nodeClick: false,
                roam: false,
                data: top_airlines.map(d => ({ name: d.airline_name, value: d.route_count })),
                breadcrumb: { show: false }, // Cleaner look
                label: {
                    show: true,
                    formatter: '{b}\n{c} routes'
                },
                leafDepth: 1,
                upperLabel: {
                    show: false
                },
                itemStyle: {
                    gapWidth: 2,
                    borderColor: '#fff'
                }
            }
        ]
    }
} />

</Grid>



```sql map_data
select * from openflights.dim_airport_hubs
where country in ${inputs.selected_country.value}
qualify rank() over(order by total_routes_supported desc) <= 20
```

```sql top_airlines
select 
    airline_name, 
    count(*) as route_count
from openflights.fct_routes
where country_of_origin in ${inputs.selected_country.value}
group by 1
order by 2 desc
limit 10
```

## 🌐 Gateway Analysis
 
Airports with the highest ratio of international to total routes — a measure of their role as global connectors. Only airports with more than 100 routes are included.

<DataTable data={hub_connectivity}>
  <Column id=airport label="Airport"/>
  <Column id=country label="Country"/>
  <Column id=total_routes label="Total Routes" align=center/>
  <Column id=international_routes label="International Routes" align=center/>
  <Column 
    id=gateway_score 
    label="Gateway Score" 
    fmt='pct1' 
    contentType=colorscale
    align=center
  />
</DataTable>


```sql hub_connectivity
select 
    source_airport_name as airport,
    country_of_origin as country,
    count(*) as total_routes,
    sum(case when is_international then 1 else 0 end) as international_routes,
    -- Calculate the "Gateway Score" (Ratio of International to Total)
    sum(case when is_international then 1.0 else 0.0 end) / count(*) as gateway_score
from openflights.fct_routes
where country_of_origin in ${inputs.selected_country.value}
group by 1, 2
having total_routes > 100 -- Filters out tiny airfields for better analysis
order by gateway_score desc
limit 15
```
