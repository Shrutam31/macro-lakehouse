select 'FXUSDCAD' as series_key, 'Bank of Canada' as source,
       'USD/CAD exchange rate' as series_name, 'CAD per USD' as unit,
       'daily' as frequency, cast(null as boolean) as seasonally_adjusted
union all
select 'V39079', 'Bank of Canada', 'Policy interest rate (target for the overnight rate)',
       'percent', 'business daily', null
union all
select '2062815', 'Statistics Canada', 'Unemployment rate, Canada, 15 years and over',
       'percent', 'monthly', true
union all
select '41690973', 'Statistics Canada', 'Consumer Price Index, all-items, Canada',
       'index', 'monthly', cast(null as boolean)