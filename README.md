
# Canadian Macro Indicators Lakehouse

An automated, tested lakehouse for Canadian macroeconomic data (Bank of Canada Valet and Statistics Canada) built on Azure Databricks, dbt and Airflow.

## Business problem
Analysts copy rates, exchange rates, inflation and unemployment figures into spreadsheets by hand. Numbers go stale, revisions silently overwrite history, and there are no quality checks. This project delivers one automated, auditable source with a dashboard.

## Stack
Azure Databricks, Delta Lake, Unity Catalog, dbt, Airflow, GitHub Actions, Power BI

## Status
**Week 1 complete: Bronze ingestion**
- Ingests Bank of Canada (Valet) and Statistics Canada (WDS) data into Delta tables on Databricks
- Raw responses stored untouched, with a SHA-256 hash of each payload
- Idempotent loads using Delta MERGE: re-running adds 0 rows
- Every run logged in `ops.ingestion_log`
- Series so far: USD/CAD, policy rate, CPI (all-items), unemployment rate

## Notes from the sources
- Valet returns values as text; Statistics Canada returns numbers
- Valet's series-details endpoint uses `seriesDetails`; the observations endpoint uses `seriesDetail`
- Statistics Canada release times suggest batch republishing; revision handling comes in Silver

## Next
**Week 2 in progress: Silver models with dbt**
- `silver_boc_observations`: parsed, typed and deduplicated Bank of Canada data (USD/CAD and policy rate)
- Statistics Canada Silver model with revision history: next
