select
    cast(vector_id as string) as series_key,
    ref_period,
    value,
    release_time
from {{ ref('silver_statcan_observations') }}
where is_current