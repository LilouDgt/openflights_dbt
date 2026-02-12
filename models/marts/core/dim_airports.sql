select
    airport_id,
    airport_name,
    city,
    country
from {{ ref('stg_airports') }}
