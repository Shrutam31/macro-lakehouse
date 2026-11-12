with snapshots as (
    select
        vector_id,
        ingested_at,
        explode(from_json(
            get_json_object(payload, '$[0].object.vectorDataPoint'),
            'array<struct<refPer:string,value:double,releaseTime:string,statusCode:int>>'
        )) as p
    from {{ source('bronze', 'statcan_raw') }}
    where http_status = 200
      and get_json_object(payload, '$[0].status') = 'SUCCESS'
),

parsed as (
    select
        vector_id,
        try_cast(p.refPer as date) as ref_period,
        p.value as value,
        try_to_timestamp(p.releaseTime, "yyyy-MM-dd'T'HH:mm") as release_time,
        p.statusCode as status_code,
        ingested_at
    from snapshots
),

with_prev as (
    select
        *,
        lag(value) over (
            partition by vector_id, ref_period order by ingested_at
        ) as prev_value,
        lag(release_time) over (
            partition by vector_id, ref_period order by ingested_at
        ) as prev_release_time,
        row_number() over (
            partition by vector_id, ref_period order by ingested_at
        ) as snapshot_no
    from parsed
),

changes as (
    select *
    from with_prev
    where snapshot_no = 1
       or not (value <=> prev_value)
       or not (release_time <=> prev_release_time)
)


-- here we will be using lead() to use SCD-type 2 ........
-- so valid to will be null if there is no next version yet released that means is_current will be true
-- but if we have new version then is current will be false and we will have the new data for validto
select
    vector_id,
    ref_period,
    value,
    release_time,
    status_code,
    ingested_at as valid_from,
    lead(ingested_at) over (
        partition by vector_id, ref_period order by ingested_at
    ) as valid_to,
    lead(ingested_at) over (
        partition by vector_id, ref_period order by ingested_at
    ) is null as is_current
from changes



--- “People 15 and over”

--This is the part of the population the rate is calculated for. Statistics Canada’s Labour Force Survey measures people aged 15 and older. Younger people are left out. So a rate of 6.7 means 6.7% of the labour force aged 15 and over was unemployed.

-- the “labour force” here means people who are working or actively looking for work. Someone who isn’t looking, such as a full-time student or a retiree, isn’t counted as unemployed.