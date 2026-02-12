select
    airline_id,
    airline_name,
    iata,
    icao,
    country
from {{ ref('stg_airlines') }}
