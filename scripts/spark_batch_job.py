#!/usr/bin/env python3
"""
Apache Spark Batch Processing Job
==================================

Part 1: Batch Processing with Apache Spark

This job performs historical analysis of sentiment for every airline:
1. Reads data from the tweets_raw_csv Hive table (or directly from CSV)
2. Performs aggregation to calculate total positive, negative, and neutral tweets per airline
3. Calculates the "negative ratio" (negative_count / total_tweets) for each airline
4. Saves results to the batch_airline_sentiment Hive table (Parquet format)
"""

import os
import sys
from datetime import datetime

try:
    from pyspark.sql import SparkSession
    from pyspark.sql.functions import col, count, when, lit, round as spark_round
    from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType
except ImportError:
    print("Error: PySpark not installed.")
    print("Run: pip install pyspark")
    sys.exit(1)


# Configuration
CSV_FILE_PATH = os.getenv('TWEETS_CSV_PATH', 'data/Tweets.csv')
OUTPUT_PATH = os.getenv('OUTPUT_PATH', 'output/batch_results_parquet')
USE_HIVE = os.getenv('USE_HIVE', 'false').lower() == 'true'


def create_spark_session():
    """Create and return a Spark session."""
    # Set Java options for Java 24 compatibility
    java_opts = "--add-opens=java.base/java.lang=ALL-UNNAMED " \
                "--add-opens=java.base/java.util=ALL-UNNAMED " \
                "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED " \
                "--add-opens=java.base/java.text=ALL-UNNAMED " \
                "--add-opens=java.desktop/java.awt.font=ALL-UNNAMED " \
                "--add-opens=java.base/javax.security.auth=ALL-UNNAMED " \
                "--add-opens=java.base/java.security=ALL-UNNAMED"

    builder = SparkSession.builder \
        .appName("Twitter Airline Sentiment Batch Analysis") \
        .config("spark.sql.parquet.compression.codec", "snappy") \
        .config("spark.driver.extraJavaOptions", java_opts) \
        .config("spark.executor.extraJavaOptions", java_opts) \
        .config("spark.master", "local[*]")

    if USE_HIVE:
        builder = builder \
            .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
            .enableHiveSupport()

    spark = builder.getOrCreate()
    spark.sparkContext.setLogLevel("WARN")

    return spark


def define_schema():
    """Define the schema for the Tweets CSV file."""
    return StructType([
        StructField("tweet_id", StringType(), True),
        StructField("airline_sentiment", StringType(), True),
        StructField("airline_sentiment_confidence", DoubleType(), True),
        StructField("negativereason", StringType(), True),
        StructField("negativereason_confidence", DoubleType(), True),
        StructField("airline", StringType(), True),
        StructField("airline_sentiment_gold", StringType(), True),
        StructField("name", StringType(), True),
        StructField("negativereason_gold", StringType(), True),
        StructField("retweet_count", IntegerType(), True),
        StructField("text", StringType(), True),
        StructField("tweet_coord", StringType(), True),
        StructField("tweet_created", StringType(), True),
        StructField("tweet_location", StringType(), True),
        StructField("user_timezone", StringType(), True)
    ])


def load_data(spark, use_hive=False):
    """Load tweet data from either Hive table or CSV file."""

    if use_hive:
        print("📂 Loading data from Hive table: tweets_raw_csv")
        df = spark.sql("SELECT * FROM tweets_raw_csv")
    else:
        print(f"📂 Loading data from CSV: {CSV_FILE_PATH}")

        if not os.path.exists(CSV_FILE_PATH):
            print(f"❌ CSV file not found: {CSV_FILE_PATH}")
            print("Please download Tweets.csv from:")
            print("https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment")
            sys.exit(1)

        df = spark.read \
            .option("header", "true") \
            .option("quote", '"') \
            .option("escape", '"') \
            .option("multiLine", "true") \
            .schema(define_schema()) \
            .csv(CSV_FILE_PATH)

    return df


def analyze_sentiment(df):
    """
    Perform sentiment analysis aggregation by airline.

    Calculates:
    - total_tweets: Total number of tweets per airline
    - positive_count: Number of positive tweets
    - negative_count: Number of negative tweets
    - neutral_count: Number of neutral tweets
    - negative_ratio: negative_count / total_tweets
    """

    print("🔄 Performing sentiment aggregation by airline...")

    # Aggregate by airline
    result = df.groupBy("airline").agg(
        count("*").alias("total_tweets"),
        count(when(col("airline_sentiment") == "positive", 1)).alias("positive_count"),
        count(when(col("airline_sentiment") == "negative", 1)).alias("negative_count"),
        count(when(col("airline_sentiment") == "neutral", 1)).alias("neutral_count")
    )

    # Calculate negative ratio
    result = result.withColumn(
        "negative_ratio",
        spark_round(
            col("negative_count").cast("double") / col("total_tweets").cast("double"),
            4
        )
    )

    # Order by total tweets descending
    result = result.orderBy(col("total_tweets").desc())

    return result


def save_results(result_df, spark, use_hive=False):
    """Save results to Parquet format (and optionally to Hive table)."""

    if use_hive:
        print("💾 Saving results to Hive table: batch_airline_sentiment")
        result_df.write \
            .mode("overwrite") \
            .format("parquet") \
            .saveAsTable("batch_airline_sentiment")
    else:
        # Try Parquet first, fall back to CSV on Windows if native Hadoop fails
        try:
            print(f"💾 Saving results to Parquet: {OUTPUT_PATH}")
            result_df.write \
                .mode("overwrite") \
                .parquet(OUTPUT_PATH)
            print("✅ Parquet results saved successfully!")
        except Exception as parquet_error:
            print(f"⚠️  Parquet save failed (Windows native lib issue): {type(parquet_error).__name__}")
            # Fallback: Save as CSV which doesn't require native Hadoop libs
            csv_output = OUTPUT_PATH.replace('_parquet', '_csv')
            print(f"💾 Falling back to CSV: {csv_output}")
            # Convert to Pandas and save to avoid Hadoop native issues
            pandas_df = result_df.toPandas()
            os.makedirs(csv_output, exist_ok=True)
            csv_file = os.path.join(csv_output, "batch_results.csv")
            pandas_df.to_csv(csv_file, index=False)
            print(f"✅ CSV results saved to: {csv_file}")


def print_results(result_df):
    """Print the analysis results to console."""

    print("\n" + "=" * 80)
    print("📊 AIRLINE SENTIMENT ANALYSIS RESULTS")
    print("=" * 80)

    # Show the results
    result_df.show(truncate=False)

    # Print detailed statistics
    print("\n📈 DETAILED STATISTICS:")
    print("-" * 80)

    rows = result_df.collect()
    total_all = sum(row['total_tweets'] for row in rows)

    for row in rows:
        airline = row['airline']
        total = row['total_tweets']
        pos = row['positive_count']
        neg = row['negative_count']
        neu = row['neutral_count']
        neg_ratio = row['negative_ratio']

        pct_of_total = (total / total_all * 100) if total_all > 0 else 0

        print(f"\n✈️  {airline}")
        print(f"   Total Tweets: {total:,} ({pct_of_total:.1f}% of all tweets)")
        print(f"   Positive: {pos:,} ({pos/total*100:.1f}%)")
        print(f"   Negative: {neg:,} ({neg/total*100:.1f}%)")
        print(f"   Neutral:  {neu:,} ({neu/total*100:.1f}%)")
        print(f"   Negative Ratio: {neg_ratio:.4f}")

    print("\n" + "=" * 80)
    print(f"📊 TOTAL TWEETS ANALYZED: {total_all:,}")
    print("=" * 80)


def main():
    """Main entry point for the Spark batch job."""

    print("=" * 80)
    print("🚀 APACHE SPARK BATCH PROCESSING JOB")
    print("   Twitter Airline Sentiment Analysis")
    print("=" * 80)
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Use Hive: {USE_HIVE}")
    print("-" * 80)

    start_time = datetime.now()

    # Create Spark session
    print("\n🔧 Initializing Spark session...")
    spark = create_spark_session()
    print(f"   Spark version: {spark.version}")

    try:
        # Load data
        df = load_data(spark, USE_HIVE)

        # Show data stats
        total_records = df.count()
        print(f"📊 Total records loaded: {total_records:,}")

        # Perform sentiment analysis
        result_df = analyze_sentiment(df)

        # Print results to console
        print_results(result_df)

        # Save results
        save_results(result_df, spark, USE_HIVE)

        # Print execution time
        elapsed = datetime.now() - start_time
        print(f"\n⏱️  Total execution time: {elapsed}")

    except Exception as e:
        print(f"\n❌ Error during processing: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

    finally:
        spark.stop()
        print("\n✅ Spark session closed.")


if __name__ == '__main__':
    main()

