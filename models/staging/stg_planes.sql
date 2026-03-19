{{ config(materialized='view', schema='staging') }}

with source as (
    select * from {{ ref('planes') }}
),

renamed as (
    select
        trim(name) as plane_model_name,
        nullif(iata, '\N') as iata_code,
        nullif(icao, '\N') as icao_code
    from source
)

select * from renamed