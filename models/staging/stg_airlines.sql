{{ config(materialized='view', schema='staging') }}

with source as (
    select * from {{ ref('airlines') }}
),

renamed as (
    select
        cast(id as int) as airline_id,
        trim(name) as airline_name,
        nullif(trim(alias), '\N') as airline_alias,
        nullif(iata, '\N') as iata_code,
        nullif(icao, '\N') as icao_code,
        nullif(trim(callsign), '\N') as callsign,
        trim(country) as country_name,
        
        -- Converting 'Y'/'N' to Boolean for better BI performance
        case 
            when active = 'Y' then true 
            else false 
        end as is_active

    from source
)

select * from renamed