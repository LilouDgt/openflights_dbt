{{ config(materialized='view', schema='staging') }}

with source as (

    select * from {{ ref('airports') }}

),

renamed_and_cleaned as (

    select
        cast(id as int) as airport_id,
        trim(name) as airport_name,
        trim(city) as city,
        trim(country) as country,
        nullif(iata, '\N') as iata_code,
        nullif(icao, '\N') as icao_code,
        cast(latitude as float) as latitude,
        cast(longitude as float) as longitude

    from source

)

select * from renamed_and_cleaned