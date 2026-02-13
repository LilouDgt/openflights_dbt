select
    r.airline_id,
    a.airline_name,

    r.source_airport_id,
    src.airport_name as source_airport_name,
    src.country as source_country,

    r.destination_airport_id,
    dst.airport_name as destination_airport_name,
    dst.country as destination_country,

    r.stops,
    r.equipment,

    case when r.stops = 0 then true else false end as is_direct

from {{ ref('stg_routes') }} r

left join {{ ref('stg_airlines') }} a
    on r.airline_id = a.airline_id

inner join {{ ref('stg_airports') }} src
    on r.source_airport_id = src.airport_id

inner join {{ ref('stg_airports') }} dst
    on r.destination_airport_id = dst.airport_id

