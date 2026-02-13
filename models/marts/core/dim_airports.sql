select
    airport_id,
    airport_name,
    city,
    country,
    latitude,
    longitude
from {{ ref('stg_airports') }}
