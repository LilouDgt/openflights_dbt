select
    airline,
    try_cast(airline_id as integer) as airline_id,
    source_airport,
    case when source_airport_id != '\N' then try_cast(source_airport_id as integer) else null end as source_airport_id,
    destination_airport,
    case when destination_airport_id != '\N' then try_cast(destination_airport_id as integer) else null end as destination_airport_id,
    codeshare,
    stops,
    equipment
from {{ ref('routes') }}
where source_airport_id != '\N' and destination_airport_id != '\N'
