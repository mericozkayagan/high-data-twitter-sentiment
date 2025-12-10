Term Project: High-Performance Analysis of Twitter Data (Template)
1. Project Overview
This project challenges you to design and build a high-performance data processing pipeline. You will implement a "Lambda-like" architecture to analyze a large Twitter dataset, handling both historical (batch) and real-time (stream) processing.

The project is divided into two main parts:

Part 1: Batch Processing: You will use Apache Spark to perform deep, historical analysis on the entire dataset.

Part 2: Stream Processing: You will choose one framework—either Apache Kafka Streams or Apache Flink—to build a real-time analytics application that processes data as if it were a live feed.

To ensure focus on the processing frameworks, we will use Apache Hive as a central metadata catalog on top of HDFS. This will provide a SQL-based interface to all our data, regardless of its underlying format.

2. Learning Objectives
Upon successful completion of this project, you will be able to:

Design and implement a modern, two-path (batch and stream) data architecture.

Master high-throughput batch processing, aggregation, and ETL using Apache Spark.

Master high-performance stream processing, including windowing and stateful transformations, using either Apache Kafka Streams or Apache Flink.

Understand and implement a "stream simulation" by replaying a static dataset through a Kafka producer.

Work with standard, high-performance data formats: Parquet (for batch) and Avro (for streaming).

Use Apache Hive as a data catalog to manage schemas for data in HDFS and provide a unified query layer.

3. Core Dataset: Twitter US Airline Sentiment
For this project, we will not use the live Twitter API. Instead, we will use a well-known, static dataset from Kaggle. This allows to work with a specific data and removes the complexities of API keys and rate limits.

Dataset: Twitter US Airline Sentiment

Download Link: https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment

File to use: Tweets.csv

Dataset Schema
The Tweets.csv file contains many columns. For this project, we are primarily interested in the following:

tweet_id (string)

airline_sentiment (string: "positive", "negative", "neutral")

airline (string: e.g., "Virgin America", "United", "Southwest")

retweet_count (integer)

text (string: The content of the tweet)

tweet_created (timestamp: e.g., "2015-02-24 11:35:52 -0800")

How and When to Use This Dataset
You will use this single Tweets.csv file in two different ways:

For Part 1 (Batch Processing): The entire Tweets.csv file represents your complete historical dataset. You will upload this file directly to HDFS (e.g., to /project/raw/tweets.csv). Your Spark job will read this entire file from HDFS to perform its historical analysis.

For Part 2 (Stream Processing): You will simulate a live stream by reading the Tweets.csv file with a simple Kafka Producer script (which you must write in Python, Java, or Scala). This script will:

Read Tweets.csv from your local machine, line by line.

Publish each line (as a JSON or Avro string) to a Kafka topic named tweets_topic.

(Optional) Add a small time.sleep(0.1) between messages to make the simulation more realistic.

Your Flink or Kafka Streams application will consume from this tweets_topic as if it were a live, unbounded stream of data.

4. System Architecture
Staging: You upload Tweets.csv to a designated directory in HDFS.

Stream Ingestion: Your Kafka Producer script reads Tweets.csv and "replays" it into a Kafka topic (tweets_topic).

Stream Processing (Part 2): Your Flink or Kafka Streams application reads from tweets_topic, performs real-time analytics, and does two things:

Sink 1 (Real-time): Outputs real-time results to the console or another Kafka topic.

Sink 2 (Persistence): Writes the raw tweet data to a new directory in HDFS as Avro files (e.g., /project/streamed_tweets_avro/).

Batch Processing (Part 1): Your Spark job runs on a schedule (or manually).

It reads the original, complete Tweets.csv file from HDFS.

It performs a large-scale aggregation.

It writes its results to a new directory in HDFS as Parquet files (e.g., /project/batch_results_parquet/).

Data Catalog (Hive): Apache Hive will be used to create external tables on top of all three HDFS locations (the raw CSV, the stream-sunk Avro, and the batch-processed Parquet), giving you SQL access to everything.

5. Storage, Formats, and Hive Schema
You must create the following Hive tables to manage your data.

1. Raw Data (Source for Batch) This table points directly to the Tweets.csv file you uploaded to HDFS.

SQL

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
2. Stream-Sunk Data (Written by Part 2) Your streaming application (Flink/Kafka) must write its raw data to this location.

SQL

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
(Note: Your streaming job must be configured to write Avro files compatible with this schema. You will also need to add partitions, e.g., MSCK REPAIR TABLE tweets_stream_avro;)

3. Batch Results (Written by Part 1) Your Spark job must write its aggregated results to this location.

SQL

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
6. Project Scenarios & Requirements
You must complete Part 1 and one track from Part 2.

Part 1: Batch Processing with Apache Spark (Required)
Goal: Perform a large-scale historical analysis of sentiment for every airline. Method: Create a Spark job (PySpark or Scala) that:

Reads data from the tweets_raw_csv Hive table.

Performs an aggregation to calculate the total number of positive, negative, and neutral tweets for each airline.

Calculates the "negative ratio" (negative_count / total_tweets) for each airline.

Saves the final result (airline, total_tweets, positive_count, negative_count, neutral_count, negative_ratio) to the batch_airline_sentiment Hive table (in Parquet format).

Part 2: Stream Processing (Choose One Track)
Goal: Perform real-time analysis on the simulated stream of tweets and persist the raw stream. Method: First, create your Kafka producer script to feed the tweets_topic. Then, choose and implement one of the following tracks.

Track 2A: The Apache Kafka Ecosystem
Frameworks: Use Kafka Streams (for processing) and Kafka Connect (for sinking).

Processing (Kafka Streams): Implement one of the "Real-Time Use Cases" below using the Kafka Streams API. The application will read from tweets_topic and write its results to the console or a new topic (e.g., realtime_alerts).

Persistence (Kafka Connect): Configure and run the Kafka Connect HDFS 3 Sink connector.

This connector must be configured to read from tweets_topic.

It must use an Avro Converter.

It must be configured to write to the HDFS location /project/streamed_tweets_avro/ and partition the data (e.g., by day and hour).

Track 2B: The Apache Flink Framework
Frameworks: Use Apache Flink (DataStream API).

Processing (Flink): Write a Flink job that consumes from the tweets_topic using the Flink Kafka Connector.

This job must implement one of the "Real-Time Use Cases" below and sink its results to the console.

Persistence (Flink): The same Flink job must have a second sink.

This sink will use Flink's FileSink connector.

It must be configured to write the raw tweet data in Avro format.

It must write to the HDFS location /project/streamed_tweets_avro/ with appropriate partitioning and file-rolling policies.

Real-Time Use Cases (Implement one for your chosen track)
Use Case A: Real-Time Airline Complaint Alerting

Scenario: An airline's PR team wants to be alerted immediately of highly negative tweets.

Task: Process the stream message by message. If a tweet's airline_sentiment is "negative", print an alert to the console (or a new Kafka topic) with the airline and the tweet text.

(e.g., "ALERT [United]: @united you lost my luggage again!")

Use Case B: Real-Time Retweet Counter (Windowed)

Scenario: A marketing team wants to see which airlines are getting the most "buzz" (retweets) every minute.

Task: Use a Tumbling Window (e.g., 1 minute). For each window, sum the retweet_count grouped by airline. At the end of each minute, print the total retweets for each airline in that window.

(e.g., "[11:36:00] Southwest: 45, United: 32, Virgin America: 12")

7. Deliverables
You must submit a single .zip file containing:

Source Code: All code for:

Part 1 (Spark Batch Job)

The Kafka Producer script

Part 2 (Your chosen Flink or Kafka Streams application)

Configuration: Any configuration files (e.g., kafka-connect-hdfs.properties if you chose Track 2A).

Project Report (PDF/Markdown):

A clear statement of which Part 2 Track (2A or 2B) you chose.

A brief description of your system's architecture.

Instructions on how to compile and run your code.

Results:

Screenshots of your stream processing job running (e.g., console output from your real-time use case).

Screenshots of SELECT queries from your three Hive tables:

SELECT * FROM tweets_raw_csv LIMIT 10;

SELECT * FROM tweets_stream_avro LIMIT 10;

SELECT * FROM batch_airline_sentiment;

A short "Discussion" section explaining any challenges you faced and why you chose your specific streaming track.


