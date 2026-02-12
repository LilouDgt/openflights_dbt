select
    id as airline_id,
    name as airline_name,
    alias,
    iata,
    icao,
    callsign,
    country,
    active
from {{ ref('airlines') }}