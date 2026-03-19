{{ config(materialized='table') }}

with airport_details as (
    select * from {{ ref('stg_airports') }}
),

final as (
    select
        -- Create a unique Hash Key (Best Practice)
        {{ dbt_utils.generate_surrogate_key(['airport_id', 'iata_code']) }} as airport_key,
        airport_id,
        airport_name,
        city,
        country,
        iata_code,
        icao_code,
        latitude,
        longitude,
        
        -- Business Logic: Categorizing by hemisphere
        case 
            when latitude > 0 then 'Northern' 
            else 'Southern' 
        end as hemisphere

    from airport_details
)

select * from final