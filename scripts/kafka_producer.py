#!/usr/bin/env python3
"""
Kafka Producer Script for Twitter Sentiment Analysis
=====================================================

This script reads the Tweets.csv file and publishes each tweet
to a Kafka topic (tweets_topic) to simulate a live stream.

Part 2 Requirement: Stream Simulation
"""

import csv
import json
import time
import os
import sys
from datetime import datetime

try:
    from kafka import KafkaProducer
    from kafka.errors import KafkaError
except ImportError:
    print("Error: kafka-python library not installed.")
    print("Run: pip install kafka-python")
    sys.exit(1)


# Configuration
KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'localhost:9092')
TOPIC_NAME = 'tweets_topic'
CSV_FILE_PATH = os.getenv('TWEETS_CSV_PATH', 'data/Tweets.csv')
MESSAGE_DELAY = 0.1  # 100ms delay between messages for realistic simulation


def create_producer():
    """Create and return a Kafka producer instance."""
    try:
        producer = KafkaProducer(
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            key_serializer=lambda k: k.encode('utf-8') if k else None,
            acks='all',
            retries=3,
            max_in_flight_requests_per_connection=1
        )
        print(f"✅ Connected to Kafka at {KAFKA_BOOTSTRAP_SERVERS}")
        return producer
    except Exception as e:
        print(f"❌ Failed to connect to Kafka: {e}")
        sys.exit(1)


def parse_tweet_row(row, headers):
    """Parse a CSV row into a tweet dictionary."""
    tweet = {}
    for i, header in enumerate(headers):
        if i < len(row):
            value = row[i].strip() if row[i] else None
            
            # Convert numeric fields
            if header == 'retweet_count':
                try:
                    tweet[header] = int(value) if value else 0
                except ValueError:
                    tweet[header] = 0
            elif header in ['airline_sentiment_confidence', 'negativereason_confidence']:
                try:
                    tweet[header] = float(value) if value else None
                except ValueError:
                    tweet[header] = None
            else:
                tweet[header] = value
    
    return tweet


def publish_tweets(producer, csv_path):
    """Read CSV file and publish tweets to Kafka."""
    
    if not os.path.exists(csv_path):
        print(f"❌ CSV file not found: {csv_path}")
        print("Please download Tweets.csv from:")
        print("https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment")
        sys.exit(1)
    
    print(f"\n📂 Reading tweets from: {csv_path}")
    print(f"📤 Publishing to topic: {TOPIC_NAME}")
    print(f"⏱️  Message delay: {MESSAGE_DELAY}s")
    print("-" * 60)
    
    total_sent = 0
    errors = 0
    sentiment_counts = {'positive': 0, 'negative': 0, 'neutral': 0}
    airline_counts = {}
    
    start_time = time.time()
    
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            headers = next(reader)  # Skip header row
            
            # Clean header names
            headers = [h.strip().lower().replace(' ', '_') for h in headers]
            
            for row_num, row in enumerate(reader, start=1):
                try:
                    tweet = parse_tweet_row(row, headers)
                    
                    # Use tweet_id as the key for partitioning
                    key = tweet.get('tweet_id', str(row_num))
                    
                    # Send to Kafka
                    future = producer.send(TOPIC_NAME, key=key, value=tweet)
                    
                    # Wait for acknowledgment (blocking)
                    future.get(timeout=10)
                    
                    total_sent += 1
                    
                    # Update statistics
                    sentiment = tweet.get('airline_sentiment', 'unknown')
                    if sentiment in sentiment_counts:
                        sentiment_counts[sentiment] += 1
                    
                    airline = tweet.get('airline', 'Unknown')
                    airline_counts[airline] = airline_counts.get(airline, 0) + 1
                    
                    # Progress update every 100 tweets
                    if total_sent % 100 == 0:
                        elapsed = time.time() - start_time
                        rate = total_sent / elapsed
                        print(f"📊 Sent: {total_sent} tweets | Rate: {rate:.1f} msg/s | "
                              f"Negative: {sentiment_counts['negative']}")
                    
                    # Add delay for realistic simulation
                    if MESSAGE_DELAY > 0:
                        time.sleep(MESSAGE_DELAY)
                        
                except Exception as e:
                    errors += 1
                    if errors <= 5:
                        print(f"⚠️  Error on row {row_num}: {e}")
                    elif errors == 6:
                        print("... suppressing further error messages ...")
    
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user")
    
    finally:
        producer.flush()
        producer.close()
    
    # Print summary
    elapsed = time.time() - start_time
    print("\n" + "=" * 60)
    print("📈 PRODUCER SUMMARY")
    print("=" * 60)
    print(f"Total tweets sent: {total_sent}")
    print(f"Errors: {errors}")
    print(f"Time elapsed: {elapsed:.2f}s")
    print(f"Average rate: {total_sent / elapsed:.2f} msg/s")
    print("\nSentiment Distribution:")
    for sentiment, count in sentiment_counts.items():
        pct = (count / total_sent * 100) if total_sent > 0 else 0
        print(f"  {sentiment}: {count} ({pct:.1f}%)")
    print("\nAirline Distribution:")
    for airline, count in sorted(airline_counts.items(), key=lambda x: -x[1]):
        pct = (count / total_sent * 100) if total_sent > 0 else 0
        print(f"  {airline}: {count} ({pct:.1f}%)")
    print("=" * 60)


def main():
    """Main entry point."""
    print("=" * 60)
    print("🐦 Twitter Kafka Producer")
    print("=" * 60)
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Check for custom CSV path from command line
    csv_path = sys.argv[1] if len(sys.argv) > 1 else CSV_FILE_PATH
    
    producer = create_producer()
    publish_tweets(producer, csv_path)


if __name__ == '__main__':
    main()

