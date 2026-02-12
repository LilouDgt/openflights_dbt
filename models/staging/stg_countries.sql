select
    name as country_name,
    iso_code,
    dafif_code
from {{ ref('countries') }}