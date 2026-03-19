{{ config(materialized='table') }}

with routes_enriched as (
    select * from {{ ref('int_routes_details') }}
),

final as (
    select

        {{ dbt_utils.generate_surrogate_key([
            'airline_id', 
            'source_airport_id', 
            'destination_airport_id', 
            'equipment_type'
        ]) }} as route_key,
        
        airline_id,
        airline_name,
        source_airport_id,
        destination_airport_id,
        
        -- Measures
        stop_count,
        is_codeshare,
        
        -- Feature Engineering: Is it an international flight?
        case 
            when source_country != destination_country then true 
            else false 
        end as is_international

    from routes_enriched
)

select * from final