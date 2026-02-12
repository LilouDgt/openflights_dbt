select 
    name as plane_name,
    iata,
    icao
from {{ ref('planes') }}