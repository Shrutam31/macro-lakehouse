select
    series_code as series_key,
    obs_date,
    value
from {{ ref('silver_boc_observations') }}
where value is not null