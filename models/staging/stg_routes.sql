select
    id as route_id,
    airport_id,
    airline_id,
    source_airport,
    destination_airport,
    codeshare,
    stops,
    equipment
from {{ ref('routes') }}
