with payloads as (
    select
        series_code,
        payload,
        ingested_at,
        size(from_json(get_json_object(payload, '$.observations'),
                       'array<struct<d:string>>')) as n_obs
    from {{ source('bronze', 'boc_raw') }}
    where http_status = 200
),

indexed as (
    select
        series_code,
        payload,
        ingested_at,
        explode(sequence(0, n_obs - 1)) as i
    from payloads
    where n_obs > 0
),

parsed as (
    select
        series_code,
        cast(get_json_object(payload, concat('$.observations[', i, '].d')) as date) as obs_date,
        get_json_object(payload, concat('$.observations[', i, '].', series_code, '.v')) as value_text,
        ingested_at
    from indexed
),

ranked as (
    select
        *,
        row_number() over (
            partition by series_code, obs_date
            order by ingested_at desc
        ) as rn
    from parsed
)

select
    series_code,
    obs_date,
    try_cast(value_text as decimal(18, 6)) as value,
    value_text,
    ingested_at
from ranked
where rn = 1