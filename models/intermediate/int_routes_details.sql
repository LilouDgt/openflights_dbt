{{ config(
    materialized='view',
    schema='intermediate'
) }}

with routes as (
    select * from {{ ref('stg_routes') }}
),

airports as (
    select * from {{ ref('stg_airports') }}
),

airlines as (
    select * from {{ ref('stg_airlines') }}
),

joined as (

    select
        routes.airline_id,
        airlines.airline_name,

        airlines.is_active as is_airline_active,
        routes.source_airport_id,
        source_airports.airport_name as source_airport_name,
        source_airports.city as source_city,
        source_airports.country as source_country,
        source_airports.latitude as source_latitude,
        source_airports.longitude as source_longitude,

        routes.destination_airport_id,
        dest_airports.airport_name as destination_airport_name,
        dest_airports.city as destination_city,
        dest_airports.country as destination_country,
        dest_airports.latitude as destination_latitude,
        dest_airports.longitude as destination_longitude,

        routes.is_codeshare,
        routes.stop_count,
        routes.equipment_type

    from routes
    
    left join airlines 
        on routes.airline_id = airlines.airline_id

    left join airports as source_airports 
        on routes.source_airport_id = source_airports.airport_id

    left join airports as dest_airports 
        on routes.destination_airport_id = dest_airports.airport_id

)

select * from joined