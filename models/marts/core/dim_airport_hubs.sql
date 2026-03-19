{{ config(
    materialized='table',
    unique_key='airport_key'
) }}

with airports as (
    select * from {{ ref('stg_airports') }}
),

-- We pull from intermediate to calculate 'Hub Status' dynamically
route_counts as (
    select 
        source_airport_id as airport_id,
        count(*) as outgoing_routes_count
    from {{ ref('int_routes_details') }}
    group by 1
),

final as (
    select
        -- 1. Create a persistent Surrogate Key using dbt_utils
        -- This is better for performance than using a raw integer ID
        {{ dbt_utils.generate_surrogate_key(['airports.airport_id', 'airports.iata_code']) }} as airport_key,
        
        airports.airport_id,
        airports.airport_name,
        airports.city,
        airports.country,
        airports.iata_code,
        airports.icao_code,
        airports.latitude,
        airports.longitude,

        -- 2. Categorization Logic (The "Analytics" part)
        case 
            when r.outgoing_routes_count > 100 then 'Global Hub'
            when r.outgoing_routes_count > 50 then 'Major Regional'
            when r.outgoing_routes_count > 0 then 'Small Commercial'
            else 'Private/Inactive'
        end as airport_category,

        -- 3. Geographic Enrichment
        case 
            when latitude > 0 then 'Northern' 
            else 'Southern' 
        end as hemisphere,

        -- 4. Audit Metadata (Recruiters love seeing this)
        coalesce(r.outgoing_routes_count, 0) as total_routes_supported,
        current_timestamp as dbt_updated_at

    from airports
    left join route_counts r 
        on airports.airport_id = r.airport_id
)

select * from final