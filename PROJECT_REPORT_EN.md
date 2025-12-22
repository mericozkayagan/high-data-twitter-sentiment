# 📄 High-Performance Analysis of Twitter Data
## Lambda Architecture Implementation - Project Report

---

## 👥 Group Members

| First Name | Last Name | Student Number |
|------------|-----------|----------------|
| Meriç | Özkayagan | 05230001155 |
| Mustafa Yiğit | Güzel | 05210000209 |
| Fatma Verda | Yüksel | 05210000299 |

---

## 1. Selected Track

### ✅ Track 2A: Apache Kafka Ecosystem

This project implements **Track 2A - Apache Kafka Ecosystem**.

| Component | Technology | Description |
|-----------|------------|-------------|
| **Processing Framework** | Apache Kafka Streams | Real-time stream processing |
| **Persistence** | Kafka Connect HDFS 3 Sink | Configuration prepared |
| **Use Case** | Use Case A | Real-Time Airline Complaint Alerting |

### Why Track 2A Was Chosen?

1. **Easy Setup:** Kafka Streams does not require a separate cluster, runs as a standard Java application
2. **Windows Compatibility:** Causes fewer issues on Windows compared to Apache Flink
3. **Low Latency:** Very low delay due to embedded operation mode
4. **Easy Scaling:** Can be easily scaled by running more instances
5. **Integrated Ecosystem:** Native integration with Kafka, Schema Registry support

---

## 2. System Architecture

### 2.1 Lambda Architecture Overview

```
                         ┌─────────────────────────────────────────────────┐
                         │              LAMBDA ARCHITECTURE                 │
                         └─────────────────────────────────────────────────┘

┌──────────────┐         ┌─────────────────┐         ┌──────────────────────┐
│              │         │                 │         │                      │
│  Tweets.csv  │────────▶│  Kafka Topic    │────────▶│  Kafka Streams App   │
│  (Kaggle)    │         │  tweets_topic   │         │  (Real-time Alerts)  │
│              │         │                 │         │                      │
└──────────────┘         └─────────────────┘         └──────────┬───────────┘
       │                                                        │
       │                                                        │
       │ Batch Path                                   Stream Path
       │                                                        │
       ▼                                                        ▼
┌──────────────────┐                               ┌────────────────────────┐
│                  │                               │                        │
│   Apache Spark   │                               │   Console Output +     │
│   (Batch Job)    │                               │   realtime_alerts      │
│                  │                               │   Kafka Topic          │
└────────┬─────────┘                               └────────────────────────┘
         │
         ▼
┌──────────────────┐
│                  │
│  Parquet/CSV     │
│  (Local Storage)  │
│                  │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│                    Apache Hive Data Catalog                  │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────┐ │
│  │ tweets_raw_csv   │  │tweets_stream_avro│  │batch_air- │ │
│  │ (External Table)│  │ (External Table) │  │line_senti-│ │
│  │                  │  │                  │  │ment       │ │
│  │ Location:        │  │ Location:        │  │           │ │
│  │ file:///tmp/     │  │ file:///tmp/     │  │ Location: │ │
│  │ project/raw/     │  │ project/streamed │  │ file:///  │ │
│  │                  │  │ _tweets_avro/    │  │ tmp/      │ │
│  │ Format: CSV      │  │ Format: Avro     │  │ project/  │ │
│  │                  │  │ Partitioned: dt  │  │ batch_   │ │
│  └──────────────────┘  └──────────────────┘  │ results_  │ │
│                                               │ parquet/  │ │
│                                               │           │ │
│                                               │ Format:   │ │
│                                               │ Parquet   │ │
│                                               └───────────┘ │
│                                                              │
│  Hive Metastore (PostgreSQL) ←─── HiveServer2 (JDBC)       │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 Component Details

#### Docker Environment (docker-compose.yml)

**Kafka Ecosystem:**
| Service | Port | Description |
|---------|------|-------------|
| Zookeeper | 2181 | Kafka coordination and cluster management |
| Kafka | 9092, 29092 | Message broker (PLAINTEXT and PLAINTEXT_HOST) |
| Schema Registry | 8081 | Avro schema management and REST API |
| Kafka UI | 8080 | Web interface (topic monitoring, consumer groups) |

**Hive Ecosystem:**
| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL | 5432 | Hive Metastore database (metadata storage) |
| Hive Metastore | 9083 | Manages table schemas and metadata |
| HiveServer2 | 10000 (JDBC), 10002 (Web UI) | JDBC/ODBC interface for SQL queries |

**Data Flow:**
- **Batch Path:** Tweets.csv → Spark → Parquet/CSV → Hive Tables
- **Stream Path:** Tweets.csv → Kafka Producer → tweets_topic → Kafka Streams → realtime_alerts

#### Kafka Topics

| Topic | Partitions | Replication Factor | Description |
|-------|------------|-------------------|-------------|
| `tweets_topic` | 3 | 1 | Raw tweet data (populated by Producer) |
| `realtime_alerts` | 3 | 1 | Negative sentiment alerts (populated by Kafka Streams) |

#### Hive Tables

| Table | Format | Location | Description |
|-------|--------|----------|-------------|
| `tweets_raw_csv` | CSV (TextFile) | `file:///tmp/project/raw/` | Raw CSV data (from Tweets.csv) |
| `tweets_stream_avro` | Avro | `file:///tmp/project/streamed_tweets_avro/` | Stream data (partitioned by dt) |
| `batch_airline_sentiment` | Parquet | `file:///tmp/project/batch_results_parquet/` | Spark batch processing results |

---

## 3. Application Components

### 3.1 Part 1: Batch Processing (Apache Spark)

**File:** `scripts/spark_batch_job.py`

**Processing Flow:**
```python
# 1. Load entire Tweets.csv as DataFrame
df = spark.read.csv("data/Tweets.csv", header=True, schema=schema)

# 2. Group by airline
result = df.groupBy("airline").agg(
    count("*").alias("total_tweets"),
    count(when(col("airline_sentiment") == "positive", 1)).alias("positive_count"),
    count(when(col("airline_sentiment") == "negative", 1)).alias("negative_count"),
    count(when(col("airline_sentiment") == "neutral", 1)).alias("neutral_count")
)

# 3. Calculate negative ratio
result = result.withColumn("negative_ratio",
    col("negative_count") / col("total_tweets")
)

# 4. Save results (Parquet/CSV)
result.write.mode("overwrite").parquet(OUTPUT_PATH)
```

**Output Schema:**
```
airline | total_tweets | positive_count | negative_count | neutral_count | negative_ratio
```

### 3.2 Part 2: Stream Processing (Kafka Streams)

**File:** `src/main/java/com/twitter/streams/SentimentAlertApp.java`

**Use Case A: Real-Time Airline Complaint Alerting**

```java
// Kafka Streams Topology
KStream<String, Tweet> tweetsStream = builder.stream("tweets_topic");

// Filter negative sentiments
tweetsStream
    .filter((key, tweet) -> "negative".equals(tweet.getAirlineSentiment()))
    .peek((key, tweet) -> printAlert(tweet))  // Print to console
    .mapValues(tweet -> formatAlert(tweet))
    .to("realtime_alerts");  // Send to new topic
```

**Features:**
- Custom Serde (TweetSerde) for JSON serialization
- Graceful shutdown (SIGINT handling)
- Both console and Kafka topic output
- Detailed alert formatting (Airline, Tweet ID, Text, Confidence, Reason, Time)

### 3.3 Kafka Producer

**File:** `scripts/kafka_producer.py`

**Operation:**
```python
# 1. Read CSV file line by line
with open('data/Tweets.csv', 'r') as f:
    reader = csv.reader(f)

    for row in reader:
        # 2. Convert each row to JSON format
        tweet = parse_tweet_row(row)

        # 3. Send to Kafka topic
        producer.send('tweets_topic', key=tweet_id, value=tweet)

        # 4. Wait 100ms for realistic simulation
        time.sleep(0.1)
```

---

## 4. Compilation and Execution Instructions

### 4.1 Requirements

| Software | Version | Purpose |
|----------|---------|---------|
| Python | 3.8+ | Producer, Spark Job |
| Java | 11+ (17 recommended) | Kafka Streams |
| Maven | 3.6+ | Java build |
| Docker Desktop | 20+ | Kafka environment |

### 4.2 Installation

#### Windows

```powershell
# 1. Navigate to project directory
cd 4-sinif\high-data

# 2. Set up Python environment
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
pip install kafka-python-ng  # For Python 3.12+

# 3. Build Java application
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"
$env:Path = "$env:JAVA_HOME\bin;C:\tools\apache-maven-3.9.6\bin;$env:Path"
mvn clean package -DskipTests

# 4. Download Tweets.csv and place in data\ folder
# https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment
```

#### Mac / Linux

```bash
# 1. Navigate to project directory
cd 4-sinif/high-data-twitter-sentiment

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Set up environment
./scripts/setup_environment.sh

# 4. Build Java application
./scripts/build_java.sh

# 5. Download Tweets.csv and place in data/ folder
# https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment
```

### 4.3 Execution

#### Windows

```powershell
# Terminal 1: Start Kafka
docker-compose up -d

# Create topics (once)
docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic tweets_topic --partitions 3 --replication-factor 1
docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic realtime_alerts --partitions 3 --replication-factor 1

# Terminal 2: Start Kafka Streams application
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
cd 4-sinif\high-data
java -cp "target\twitter-sentiment-analysis-1.0.0.jar" com.twitter.streams.SentimentAlertApp

# Terminal 3: Run Producer
cd 4-sinif\high-data
.\venv\Scripts\python.exe .\scripts\kafka_producer.py

# Terminal 4: Run Spark batch job
$env:HADOOP_HOME = "C:\hadoop"  # For Windows
.\venv\Scripts\python.exe .\scripts\spark_batch_job.py
```

#### Mac / Linux

```bash
# Terminal 1: Start Kafka and Hive services
cd 4-sinif/high-data-twitter-sentiment
docker-compose up -d

# Create topics (once)
./scripts/create_topics.sh

# Create Hive tables (once)
docker cp scripts/hive_tables.sql hive-server:/tmp/
docker exec hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p "" -f /tmp/hive_tables.sql

# Terminal 2: Start Kafka Streams application
cd 4-sinif/high-data-twitter-sentiment
./scripts/run_streams_app.sh

# Terminal 3: Run Producer
cd 4-sinif/high-data-twitter-sentiment
source venv/bin/activate
./scripts/run_producer.sh

# Terminal 4: Run Spark batch job
cd 4-sinif/high-data-twitter-sentiment
source venv/bin/activate
./scripts/run_spark_job.sh

# Terminal 5: Run Hive queries
docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""
# Inside Beeline:
SELECT * FROM tweets_raw_csv LIMIT 10;
SELECT * FROM tweets_stream_avro LIMIT 10;
SELECT * FROM batch_airline_sentiment;
```

---

## 5. Results

### 5.1 Kafka UI - Topics List

Kafka UI (http://localhost:8080) can be used to monitor cluster status and topics. The screenshot below shows that `tweets_topic` and `realtime_alerts` topics have been created and contain messages.

![Kafka Topics List](screenshots/topics.jpeg)

**Visible Information:**
- `tweets_topic`: 3 partitions, message count visible
- `realtime_alerts`: 3 partitions, message count visible
- Partition and replication information for each topic

### 5.2 Tweets Topic Details

Tweet messages sent by the Producer can be viewed in `tweets_topic`. The screenshot shows topic details, partition information, and message contents.

![Tweets Topic Details](screenshots/tweets_topic.jpeg)

**Visible Information:**
- Topic name: `tweets_topic`
- Number of partitions: 3
- Message count and size
- Topic configuration

### 5.3 Realtime Alerts Topic Details

Negative sentiment alerts produced by Kafka Streams can be viewed in `realtime_alerts` topic.

![Realtime Alerts Topic](screenshots/realtime_alerts_topic.jpeg)

**Visible Information:**
- Topic name: `realtime_alerts`
- Number of partitions: 3
- Alert message count
- Stream processing results

### 5.4 Kafka Brokers

The status and metrics of brokers in the Kafka cluster can be viewed.

![Kafka Brokers](screenshots/brokers.jpeg)

**Visible Information:**
- Broker ID: 1
- Broker status: UP
- Disk and network metrics
- Cluster health status

### 5.5 Consumer Groups - sentiment-alert-app

The consumer group status and partition assignments of the Kafka Streams application can be viewed.

![Consumer Group: sentiment-alert-app](screenshots/sentiment-alert-app-consumer.jpeg)

**Visible Information:**
- Consumer group name: `sentiment-alert-app`
- State: ACTIVE
- Partition assignments
- Offset and lag information
- Topics: `tweets_topic` and `realtime_alerts`

### 5.3 Kafka Streams Console Output (Real-Time Alerts)

Alert examples printed to console when negative sentiment is detected:

```
================================================================================
NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: Virgin America
Tweet ID: 570301031407624196
Text: @VirginAmerica it's really aggressive to blast obnoxious "entertainment" in your guests' faces &amp; they have little recourse
Confidence: 1.0
Reason: Bad Flight
Time: 2015-02-24 11:15:36 -0800
================================================================================

================================================================================
NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: Virgin America
Tweet ID: 570300817074462722
Text: @VirginAmerica and it's a really big bad thing about it
Confidence: 1.0
Reason: Can't Tell
Time: 2015-02-24 11:14:45 -0800
================================================================================

================================================================================
NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: Virgin America
Tweet ID: 570114021854212096
Text: @VirginAmerica hi! I just bked a cool birthday trip with you, but i can't add my elevate no. cause i entered my middle name during Flight Booking Problems 😢
Confidence: 1.0
Reason: Flight Booking Problems
Time: 2015-02-23 22:52:29 -0800
================================================================================

================================================================================
NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: Virgin America
Tweet ID: 569564610837086209
Text: @VirginAmerica our flight into lga was Cancelled Flighted. We're stuck in Dallas. I called to reschedule, told I could get a flight for today...(1/2)
Confidence: 1.0
Reason: Cancelled Flight
Time: 2015-02-22 10:29:19 -0800
================================================================================

================================================================================
NEGATIVE SENTIMENT DETECTED!
================================================================================
Airline: Virgin America
Tweet ID: 569540405676654592
Text: @VirginAmerica - Your site seems a little wonked right now. May want to have a look. Tried on two browsers. No CSS? http://t.co/8qsQMM7KF2
Confidence: 0.68
Reason: Customer Service Issue
Time: 2015-02-22 08:53:08 -0800
================================================================================
```

**Note:** The Kafka Streams application reads messages from `tweets_topic` in real-time, filters negative sentiment tweets, and prints alerts to console as well as sends them to `realtime_alerts` topic.

### 5.4 Kafka Producer Console Output

```
============================================================
🐦 Twitter Kafka Producer
============================================================
Timestamp: 2025-12-10 21:39:16
✅ Connected to Kafka at localhost:9092

📂 Reading tweets from: data/Tweets.csv
📤 Publishing to topic: tweets_topic
⏱️  Message delay: 0.1s
------------------------------------------------------------
📊 Sent: 100 tweets | Rate: 9.8 msg/s | Negative: 35
📊 Sent: 200 tweets | Rate: 9.7 msg/s | Negative: 83
📊 Sent: 300 tweets | Rate: 9.7 msg/s | Negative: 120
📊 Sent: 400 tweets | Rate: 9.7 msg/s | Negative: 166
...
📊 Sent: 2000 tweets | Rate: 9.7 msg/s | Negative: 1250
```

### 5.5 Spark Batch Job Results

#### Console Output

```
================================================================================
🚀 APACHE SPARK BATCH PROCESSING JOB
   Twitter Airline Sentiment Analysis
================================================================================
Timestamp: 2025-12-10 21:42:21
Spark version: 3.5.0

📂 Loading data from CSV: data/Tweets.csv
📊 Total records loaded: 14,640
🔄 Performing sentiment aggregation by airline...

================================================================================
📊 AIRLINE SENTIMENT ANALYSIS RESULTS
================================================================================
+--------------+------------+--------------+--------------+-------------+--------------+
|airline       |total_tweets|positive_count|negative_count|neutral_count|negative_ratio|
+--------------+------------+--------------+--------------+-------------+--------------+
|United        |3822        |492           |2633          |697          |0.6889        |
|US Airways    |2913        |269           |2263          |381          |0.7769        |
|American      |2759        |336           |1960          |463          |0.7104        |
|Southwest     |2420        |570           |1186          |664          |0.4901        |
|Delta         |2222        |544           |955           |723          |0.4298        |
|Virgin America|504         |152           |181           |171          |0.3591        |
+--------------+------------+--------------+--------------+-------------+--------------+

📈 DETAILED STATISTICS:
--------------------------------------------------------------------------------
✈️  United
   Total Tweets: 3,822 (26.1% of all tweets)
   Positive: 492 (12.9%)
   Negative: 2,633 (68.9%)
   Neutral:  697 (18.2%)
   Negative Ratio: 0.6889

✈️  US Airways
   Total Tweets: 2,913 (19.9% of all tweets)
   Positive: 269 (9.2%)
   Negative: 2,263 (77.7%)
   Neutral:  381 (13.1%)
   Negative Ratio: 0.7769

✈️  American
   Total Tweets: 2,759 (18.8% of all tweets)
   Positive: 336 (12.2%)
   Negative: 1,960 (71.0%)
   Neutral:  463 (16.8%)
   Negative Ratio: 0.7104

✈️  Southwest
   Total Tweets: 2,420 (16.5% of all tweets)
   Positive: 570 (23.6%)
   Negative: 1,186 (49.0%)
   Neutral:  664 (27.4%)
   Negative Ratio: 0.4901

✈️  Delta
   Total Tweets: 2,222 (15.2% of all tweets)
   Positive: 544 (24.5%)
   Negative: 955 (43.0%)
   Neutral:  723 (32.5%)
   Negative Ratio: 0.4298

✈️  Virgin America
   Total Tweets: 504 (3.4% of all tweets)
   Positive: 152 (30.2%)
   Negative: 181 (35.9%)
   Neutral:  171 (33.9%)
   Negative Ratio: 0.3591

================================================================================
📊 TOTAL TWEETS ANALYZED: 14,640
================================================================================
💾 Results saved to: output/batch_results_csv/batch_results.csv
💾 Results saved to: output/batch_results_parquet/ (Parquet format)

⏱️  Total execution time: ~10-15 seconds
✅ Spark session closed.
```

#### batch_airline_sentiment Table (Batch Results)

```csv
airline,total_tweets,positive_count,negative_count,neutral_count,negative_ratio
United,3822,492,2633,697,0.6889
US Airways,2913,269,2263,381,0.7769
American,2759,336,1960,463,0.7104
Southwest,2420,570,1186,664,0.4901
Delta,2222,544,955,723,0.4298
Virgin America,504,152,181,171,0.3591
```

### 5.6 Hive Server Web UI

HiveServer2 Web UI (http://localhost:10002) can be used to view Hive configuration and server status.

![Hive Server Web UI](screenshots/hive-ui.jpeg)

**Visible Information:**
- HiveServer2 status
- Configuration information
- Server metrics
- Hive version and build information

### 5.7 Hive Tables (SQL Queries)

> **Note:** Hive tables are accessible through HiveServer2 running in Docker containers.
> Queries can be executed using Beeline command-line tool or HiveServer2 Web UI (http://localhost:10002).

#### Hive Connection

**Connecting with Beeline:**
```bash
docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""
```

#### 1. tweets_raw_csv (Raw Data)

**Table Definition:**
- **Format:** CSV (TextFile)
- **Serde:** OpenCSVSerde
- **Location:** `file:///tmp/project/raw/`
- **Schema:** 15 columns (tweet_id, airline_sentiment, airline, text, etc.)

**Query:**
```sql
SELECT * FROM tweets_raw_csv LIMIT 10;
```

**Actual Output:**
```
Connected to: Apache Hive (version 4.0.0)
Driver: Hive JDBC (version 4.0.0)
Transaction isolation: TRANSACTION_REPEATABLE_READ
INFO  : Compiling command(queryId=hive_20251222173954_f30b0f36-3387-44d5-8ca2-afbb47d5f566): SELECT * FROM tweets_raw_csv LIMIT 10
INFO  : Semantic Analysis Completed (retrial = false)
INFO  : Created Hive schema: Schema(fieldSchemas:[FieldSchema(name=tweets_raw_csv.tweet_id, type:string, comment:null), FieldSchema(name=tweets_raw_csv.airline_sentiment, type:string, comment:null), ...])
INFO  : Completed compiling command; Time taken: 0.175 seconds
INFO  : Executing command: SELECT * FROM tweets_raw_csv LIMIT 10
INFO  : Completed executing command; Time taken: 0.0 seconds
+--------------------------+-----------------------------------+----------------------------------------------+--------------------------------+-------------------------------------------+-------------------------+
| tweets_raw_csv.tweet_id  | tweets_raw_csv.airline_sentiment  | tweets_raw_csv.airline_sentiment_confidence  | tweets_raw_csv.negativereason  | tweets_raw_csv.negativereason_confidence  | tweets_raw_csv.airline  |
+--------------------------+-----------------------------------+----------------------------------------------+--------------------------------+-------------------------------------------+-------------------------+
+--------------------------+-----------------------------------+----------------------------------------------+--------------------------------+-------------------------------------------+-------------------------+
No rows selected (0.233 seconds)
```

> **Note:** The table has been created but no data has been loaded yet. When data is loaded, CSV-formatted tweet data will be displayed. The table is defined as an external table and reads CSV files from the `file:///tmp/project/raw/` directory.

#### 2. tweets_stream_avro (Stream-Sunk Data)

**Table Definition:**
- **Format:** Avro
- **Location:** `file:///tmp/project/streamed_tweets_avro/`
- **Partitioned By:** dt (date string)
- **Schema:** tweet_id, airline_sentiment, airline, retweet_count, text, tweet_created

**Query:**
```sql
SELECT * FROM tweets_stream_avro LIMIT 10;
```

**Actual Output:**
```
Connected to: Apache Hive (version 4.0.0)
Driver: Hive JDBC (version 4.0.0)
Transaction isolation: TRANSACTION_REPEATABLE_READ
INFO  : Compiling command(queryId=hive_20251222173957_d9c4b228-58fb-44e4-ac22-8f159604e939): SELECT * FROM tweets_stream_avro LIMIT 10
INFO  : Semantic Analysis Completed (retrial = false)
INFO  : Created Hive schema: Schema(fieldSchemas:[FieldSchema(name=tweets_stream_avro.tweet_id, type:string, comment:null), FieldSchema(name=tweets_stream_avro.airline_sentiment, type:string, comment:null), FieldSchema(name=tweets_stream_avro.airline, type:string, comment:null), FieldSchema(name=tweets_stream_avro.retweet_count, type:int, comment:null), FieldSchema(name=tweets_stream_avro.text, type:string, comment:null), FieldSchema(name=tweets_stream_avro.tweet_created, type:string, comment:null), FieldSchema(name=tweets_stream_avro.dt, type:string, comment:null)])
INFO  : Completed compiling command; Time taken: 0.208 seconds
INFO  : Executing command: SELECT * FROM tweets_stream_avro LIMIT 10
INFO  : Completed executing command; Time taken: 0.0 seconds
+------------------------------+---------------------------------------+-----------------------------+-----------------------------------+--------------------------+-----------------------------------+------------------------+
| tweets_stream_avro.tweet_id  | tweets_stream_avro.airline_sentiment  | tweets_stream_avro.airline  | tweets_stream_avro.retweet_count  | tweets_stream_avro.text  | tweets_stream_avro.tweet_created  | tweets_stream_avro.dt  |
+------------------------------+---------------------------------------+-----------------------------+-----------------------------------+--------------------------+-----------------------------------+------------------------+
+------------------------------+---------------------------------------+-----------------------------+-----------------------------------+--------------------------+-----------------------------------+------------------------+
No rows selected (0.275 seconds)
```

> **Note:** The table has been created but no stream data has been loaded yet. When Kafka Connect HDFS Sink is used, Avro-formatted stream data will be loaded into this table. The table is partitioned by the `dt` (date) column for date-based partitions. To discover partitions, run `MSCK REPAIR TABLE tweets_stream_avro;`.

#### 3. batch_airline_sentiment (Batch Results) ⭐

**Table Definition:**
- **Format:** Parquet (Snappy compression)
- **Location:** `file:///tmp/project/batch_results_parquet/`
- **Schema:** airline, total_tweets, positive_count, negative_count, neutral_count, negative_ratio

**Query:**
```sql
SELECT * FROM batch_airline_sentiment;
```

**Actual Output:**
```
Connected to: Apache Hive (version 4.0.0)
Driver: Hive JDBC (version 4.0.0)
Transaction isolation: TRANSACTION_REPEATABLE_READ
INFO  : Compiling command(queryId=hive_20251222174000_be5f8515-f0b7-4c0d-b14c-d98a127cad74): SELECT * FROM batch_airline_sentiment
INFO  : No Stats for default@batch_airline_sentiment, Columns: total_tweets, positive_count, neutral_count, negative_ratio, negative_count, airline
INFO  : Semantic Analysis Completed (retrial = false)
INFO  : Created Hive schema: Schema(fieldSchemas:[FieldSchema(name=batch_airline_sentiment.airline, type:string, comment:null), FieldSchema(name=batch_airline_sentiment.total_tweets, type:bigint, comment:null), FieldSchema(name=batch_airline_sentiment.positive_count, type:bigint, comment:null), FieldSchema(name=batch_airline_sentiment.negative_count, type:bigint, comment:null), FieldSchema(name=batch_airline_sentiment.neutral_count, type:bigint, comment:null), FieldSchema(name=batch_airline_sentiment.negative_ratio, type:double, comment:null)])
INFO  : Completed compiling command; Time taken: 0.063 seconds
INFO  : Executing command: SELECT * FROM batch_airline_sentiment
INFO  : Completed executing command; Time taken: 0.0 seconds
+----------------------------------+---------------------------------------+-----------------------------------------+-----------------------------------------+----------------------------------------+-----------------------------------------+
| batch_airline_sentiment.airline  | batch_airline_sentiment.total_tweets  | batch_airline_sentiment.positive_count  | batch_airline_sentiment.negative_count  | batch_airline_sentiment.neutral_count  | batch_airline_sentiment.negative_ratio  |
+----------------------------------+---------------------------------------+-----------------------------------------+-----------------------------------------+----------------------------------------+-----------------------------------------+
+----------------------------------+---------------------------------------+-----------------------------------------+-----------------------------------------+----------------------------------------+-----------------------------------------+
No rows selected (0.129 seconds)
```

**Note:** The table has been created. When the Spark batch job is executed and Parquet files are saved to the `file:///tmp/project/batch_results_parquet/` directory, the following results will be displayed.

**Expected Result (When Spark Batch Job is Executed):**
| airline | total_tweets | positive_count | negative_count | neutral_count | negative_ratio |
|---------|--------------|----------------|----------------|---------------|----------------|
| United | 3822 | 492 | 2633 | 697 | 0.6889 |
| US Airways | 2913 | 269 | 2263 | 381 | 0.7769 |
| American | 2759 | 336 | 1960 | 463 | 0.7104 |
| Southwest | 2420 | 570 | 1186 | 664 | 0.4901 |
| Delta | 2222 | 544 | 955 | 723 | 0.4298 |
| Virgin America | 504 | 152 | 181 | 171 | 0.3591 |

**Actual Batch Results (from CSV):**
```csv
airline,total_tweets,positive_count,negative_count,neutral_count,negative_ratio
United,3822,492,2633,697,0.6889
US Airways,2913,269,2263,381,0.7769
American,2759,336,1960,463,0.7104
Southwest,2420,570,1186,664,0.4901
Delta,2222,544,955,723,0.4298
Virgin America,504,152,181,171,0.3591
```

> **IMPORTANT:** This table is populated after running the Spark batch job. It is one of the mandatory screenshots for the assignment.

#### Checking Hive Tables

**List all tables:**
```sql
SHOW TABLES;
```

**View table schema:**
```sql
DESCRIBE batch_airline_sentiment;
```

**Check table record count:**
```sql
SELECT COUNT(*) FROM batch_airline_sentiment;
```

---

## 6. Discussion

### 6.1 Challenges Encountered

#### Challenge 1: Kafka and Spark Setup on Windows/Mac Environment

**Problem:** Native Kafka and Spark installation on Windows and Mac is complex. Especially HADOOP_HOME and winutils.exe requirements cause issues.

**Solution:**
- Docker Compose used for Kafka ecosystem (works on all platforms)
- CSV fallback mechanism added for Spark (instead of Parquet)
- `kafka-python-ng` package used (for Python 3.12+ compatibility)
- Docker containers used for Hive (eliminated HDFS requirement)

#### Challenge 2: CSV Parsing

**Problem:** Commas, quotation marks, and multi-line content in tweet texts made CSV parsing difficult.

**Solution:**
- `multiLine=true` and proper quote handling used in Spark
- Custom CSV parsing logic implemented

#### Challenge 3: Kafka-Python Compatibility

**Problem:** Standard `kafka-python` package is incompatible with Python 3.12+ (`distutils` module removed).

**Solution:** Actively maintained `kafka-python-ng` fork used.

#### Challenge 4: JSON Serialization

**Problem:** Serializing/deserializing Tweet objects in Kafka Streams.

**Solution:** Custom Serde (TweetSerde) implementation - Jackson JSON library used.

#### Challenge 5: Creating Hive Tables

**Problem:** Creating Hive tables and accessing data without HDFS.

**Solution:**
- Hive tables defined as external tables
- Local file system used (`file:///tmp/project/...`)
- PostgreSQL used as Hive Metastore
- SQL queries executed using Beeline command-line tool
- HiveServer2 Web UI (http://localhost:10002) used for status monitoring

### 6.2 Rationale for Choosing Track 2A

**Reasons for choosing Apache Kafka Streams:**

1. **Embedded Architecture:** Does not require a separate cluster, runs as a standard Java application
2. **Exactly-Once Semantics:** Exactly-once processing guarantee thanks to native integration with Kafka
3. **State Management:** Built-in state store support (RocksDB)
4. **Windows Compatibility:** Fewer issues on Windows compared to Flink
5. **Learning Curve:** DSL API is intuitive and easy to learn
6. **Operational Simplicity:** Does not require a separate resource manager (YARN, Mesos)

### 6.3 Results and Evaluation

This project successfully:

- ✅ Implemented Lambda architecture
- ✅ Performed batch processing with Apache Spark (14,640 tweet analysis)
- ✅ Performed real-time stream processing with Kafka Streams
- ✅ Established negative sentiment detection and alerting system
- ✅ Ran Kafka ecosystem in Docker environment
- ✅ Established Apache Hive Data Catalog and created 3 tables
- ✅ Configured PostgreSQL as Hive Metastore
- ✅ Executed SQL queries with HiveServer2

**Statistics:**
- Total tweets: 14,640
- 6 airlines analyzed
- Highest negative ratio: US Airways (77.7%)
- Lowest negative ratio: Virgin America (35.9%)
- Stream processing speed: ~9.7 msg/s
- Hive tables: 3 (tweets_raw_csv, tweets_stream_avro, batch_airline_sentiment)
- Docker services: 7 (Zookeeper, Kafka, Schema Registry, Kafka UI, PostgreSQL, Hive Metastore, HiveServer2)

---

## 7. Project Structure

```
high-data-twitter-sentiment/
├── src/main/java/com/twitter/streams/    # Java Kafka Streams applications
│   ├── Tweet.java                        # Tweet data model
│   ├── TweetSerde.java                   # Kafka Serde (Serializer/Deserializer)
│   ├── SentimentAlertApp.java            # Use Case A: Negative tweet alerts
│   └── RetweetCounterApp.java            # Use Case B: Windowed retweet counter
│
├── scripts/
│   ├── kafka_producer.py                 # Python Kafka Producer
│   ├── spark_batch_job.py                # PySpark Batch Processing
│   ├── hive_tables.sql                   # Hive table definitions
│   ├── *.sh                              # Mac/Linux shell scripts
│   └── *.bat                             # Windows batch scripts
│
├── config/
│   ├── application.properties            # Application settings
│   └── kafka-connect-hdfs.properties     # Kafka Connect HDFS sink config
│
├── data/                                 # Tweets.csv data file
├── output/                               # Spark batch outputs
│   ├── batch_results_csv/               # Results in CSV format
│   └── batch_results_parquet/           # Results in Parquet format
├── images/                               # Screenshots
├── docker-compose.yml                    # Docker environment (Kafka + Hive)
├── pom.xml                               # Maven build file
├── requirements.txt                      # Python dependencies
└── PROJECT_REPORT.md                     # This report (Turkish)
└── PROJECT_REPORT_EN.md                  # This report (English)
```

---

## 8. References

1. **Dataset:** [Kaggle - Twitter US Airline Sentiment](https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment)
2. **Apache Kafka Streams:** [kafka.apache.org/documentation/streams](https://kafka.apache.org/documentation/streams/)
3. **Apache Spark SQL Guide:** [spark.apache.org/docs/latest/sql-programming-guide.html](https://spark.apache.org/docs/latest/sql-programming-guide.html)
4. **Apache Hive:** [hive.apache.org](https://hive.apache.org/)
5. **Confluent Platform:** [docs.confluent.io](https://docs.confluent.io/)

---

**Report Date:** December 2025

**Course:** High-Performance Data Processing (4th Year)

