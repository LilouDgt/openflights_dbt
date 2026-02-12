select
    id as airport_id,
    name as airport_name,
    city,
    country,
    iata,
    icao,
    latitude,
    longitude
from {{ ref('airports') }}
