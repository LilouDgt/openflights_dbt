{{ config(materialized='view', schema='staging') }}


with source as (

    select * from {{ ref('routes') }}

),

renamed_and_cleaned as (

    select
        cast(nullif(airline_id, '\N') as int) as airline_id,
        cast(nullif(source_airport_id, '\N') as int) as source_airport_id,
        cast(nullif(destination_airport_id, '\N') as int) as destination_airport_id,
        trim(airline) as airline_code,
        trim(source_airport) as source_airport_code,
        trim(destination_airport) as destination_airport_code,
        case when codeshare = 'Y' then true else false end as is_codeshare,
        cast(stops as int) as stop_count,
        trim(equipment) as equipment_type

    from source

)

select * from renamed_and_cleaned