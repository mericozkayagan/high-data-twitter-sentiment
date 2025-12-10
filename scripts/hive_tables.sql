-- ============================================================================
-- HIVE TABLE DEFINITIONS
-- Twitter Airline Sentiment Analysis - Lambda Architecture
-- ============================================================================

-- ============================================================================
-- 1. RAW DATA TABLE (Source for Batch Processing)
-- Points directly to the Tweets.csv file uploaded to HDFS
-- ============================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS tweets_raw_csv (
    tweet_id STRING,
    airline_sentiment STRING,
    airline_sentiment_confidence DOUBLE,
    negativereason STRING,
    negativereason_confidence DOUBLE,
    airline STRING,
    airline_sentiment_gold STRING,
    name STRING,
    negativereason_gold STRING,
    retweet_count INT,
    text STRING,
    tweet_coord STRING,
    tweet_created STRING,
    tweet_location STRING,
    user_timezone STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   "separatorChar" = ',',
   "quoteChar"     = '"'
)
STORED AS TEXTFILE
LOCATION '/project/raw/'
TBLPROPERTIES ("skip.header.line.count"="1");


-- ============================================================================
-- 2. STREAM-SUNK DATA TABLE (Written by Part 2 - Kafka Streams/Connect)
-- Your streaming application writes raw data to this location in Avro format
-- ============================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS tweets_stream_avro (
    tweet_id STRING,
    airline_sentiment STRING,
    airline STRING,
    retweet_count INT,
    text STRING,
    tweet_created STRING
)
PARTITIONED BY (dt STRING)
STORED AS AVRO
LOCATION '/project/streamed_tweets_avro/';

-- After streaming data is written, run this to discover partitions:
-- MSCK REPAIR TABLE tweets_stream_avro;


-- ============================================================================
-- 3. BATCH RESULTS TABLE (Written by Part 1 - Spark)
-- Spark job writes aggregated sentiment results here in Parquet format
-- ============================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS batch_airline_sentiment (
    airline STRING,
    total_tweets BIGINT,
    positive_count BIGINT,
    negative_count BIGINT,
    neutral_count BIGINT,
    negative_ratio DOUBLE
)
STORED AS PARQUET
LOCATION '/project/batch_results_parquet/';


-- ============================================================================
-- VERIFICATION QUERIES
-- Use these queries to verify data in each table
-- ============================================================================

-- Verify raw CSV data:
-- SELECT * FROM tweets_raw_csv LIMIT 10;

-- Verify streamed Avro data:
-- SELECT * FROM tweets_stream_avro LIMIT 10;

-- Verify batch processing results:
-- SELECT * FROM batch_airline_sentiment;

-- Count records in each table:
-- SELECT 'tweets_raw_csv' as table_name, COUNT(*) as row_count FROM tweets_raw_csv
-- UNION ALL
-- SELECT 'tweets_stream_avro' as table_name, COUNT(*) as row_count FROM tweets_stream_avro
-- UNION ALL
-- SELECT 'batch_airline_sentiment' as table_name, COUNT(*) as row_count FROM batch_airline_sentiment;

