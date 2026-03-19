{{ config(
    materialized='table',
    unique_key='airline_key'
) }}

with airlines as (

    select * from {{ ref('stg_airlines') }}

),

-- Calculate operational metrics from our Intermediate layer
airline_stats as (

    select 
        airline_id,
        count(*) as total_routes_count,
        count(distinct source_airport_id) as unique_source_airports
    from {{ ref('int_routes_details') }}
    group by 1

),

final as (

    select
        -- 1. Surrogate Key (Hashing the ID + Name for a robust unique identifier)
        {{ dbt_utils.generate_surrogate_key(['airlines.airline_id', 'airlines.airline_name']) }} as airline_key,
        
        airlines.airline_id,
        airlines.airline_name,
        airlines.iata_code,
        airlines.icao_code,
        airlines.callsign,
        airlines.country_name,
        airlines.is_active,

        -- 2. Business Logic: Scale of Operation
        case 
            when s.total_routes_count > 500 then 'Major Global Carrier'
            when s.total_routes_count > 100 then 'Regional Carrier'
            when s.total_routes_count > 0 then 'Local/Specialty'
            else 'Inactive/No Routes'
        end as airline_market_segment,

        -- 3. Metrics (Denormalized for easy reporting)
        coalesce(s.total_routes_count, 0) as total_active_routes,
        coalesce(s.unique_source_airports, 0) as total_hubs_served,
        
        -- 4. Audit Metadata
        current_timestamp as dbt_updated_at

    from airlines
    left join airline_stats s 
        on airlines.airline_id = s.airline_id

)

select * from final