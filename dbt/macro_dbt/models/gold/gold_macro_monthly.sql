with bounds as (
    select date_trunc('month', min(obs_date)) as first_month,
           date_trunc('month', max(obs_date)) as last_month
    from {{ ref('fact_boc_daily') }}
),

months as (
    select explode(sequence(first_month, last_month, interval 1 month)) as month
    from bounds
),

fx as (
    select date_trunc('month', obs_date) as month,
           avg(value) as usdcad_avg,
           count(*) as fx_days
    from {{ ref('fact_boc_daily') }}
    where series_key = 'FXUSDCAD'
    group by 1
),

policy as (
    select date_trunc('month', obs_date) as month,
           max_by(value, obs_date) as policy_rate_eom
    from {{ ref('fact_boc_daily') }}
    where series_key = 'V39079'
    group by 1
),

unemp as (
    select ref_period as month, value as unemployment_rate
    from {{ ref('fact_statcan_monthly') }}
    where series_key = '2062815'
),

cpi as (
    select ref_period as month, value as cpi_index
    from {{ ref('fact_statcan_monthly') }}
    where series_key = '41690973'
)

select
    m.month,
    round(fx.usdcad_avg, 4) as usdcad_avg,
    fx.fx_days,
    policy.policy_rate_eom,
    cpi.cpi_index,
    round((cpi.cpi_index / cpi_prev.cpi_index - 1) * 100, 2) as cpi_yoy_pct,
    unemp.unemployment_rate
from months m
left join fx on fx.month = m.month
left join policy on policy.month = m.month
left join cpi on cpi.month = m.month
left join cpi as cpi_prev on cpi_prev.month = add_months(m.month, -12)
left join unemp on unemp.month = m.month