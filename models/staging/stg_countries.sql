{{ config(materialized='view', schema='staging') }}

with source as (
    select * from {{ ref('countries') }}
),

renamed as (
    select
        trim(name) as country_name,
        nullif(iso_code, '\N') as iso_2_code,
        nullif(dafif_code, '\N') as dafif_code
    from source
)

select * from renamed