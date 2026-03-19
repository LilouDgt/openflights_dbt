{{ config(
    materialized='view',
    schema='intermediate'
) }}

with all_route_airports as (
    select source_airport_id as airport_id from {{ ref('stg_routes') }}
    union
    select destination_airport_id as airport_id from {{ ref('stg_routes') }}
),

missing_airports as (
    -- Identify IDs that don't exist in the master airport list
    select distinct 
        ra.airport_id
    from all_route_airports ra
    left join {{ ref('stg_airports') }} a 
        on ra.airport_id = a.airport_id
    where a.airport_id is null 
      and ra.airport_id is not null
)

select 
    airport_id,
    'Unknown Airport' as airport_name,
    'Data Gap' as city,
    'Missing from Source' as country,
    true as is_ghost_airport
from missing_airports