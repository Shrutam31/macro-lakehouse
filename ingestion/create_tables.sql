%sql
CREATE TABLE IF NOT EXISTS macro.bronze.statcan_raw (
  run_id STRING,
  ingested_at TIMESTAMP,
  request_key STRING,
  request_url STRING,
  vector_id BIGINT,
  http_status INT,
  payload STRING,
  payload_sha256 STRING
) USING DELTA;

CREATE TABLE IF NOT EXISTS macro.ops.ingestion_log (
  run_id STRING,
  source STRING,
  started_at TIMESTAMP,
  finished_at TIMESTAMP,
  status STRING,
  rows_fetched INT,
  rows_new INT,
  error_message STRING
) USING DELTA;

%sql
CREATE TABLE IF NOT EXISTS macro.bronze.boc_raw (
  run_id STRING,
  ingested_at TIMESTAMP,
  request_key STRING,
  request_url STRING,
  series_code STRING,
  http_status INT,
  payload STRING,
  payload_sha256 STRING
) USING DELTA;