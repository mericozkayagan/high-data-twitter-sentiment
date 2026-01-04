#!/bin/bash
# ============================================================================
# Create Kafka Topics
# ============================================================================

echo "============================================================================"
echo " Creating Kafka Topics"
echo "============================================================================"
echo ""

cd "$(dirname "$0")/.."

# Create tweets_topic
echo "Creating tweets_topic..."
docker exec kafka kafka-topics --bootstrap-server localhost:9092 \
    --create --topic tweets_topic \
    --partitions 3 --replication-factor 1 \
    --if-not-exists

# Create realtime_alerts topic
echo "Creating realtime_alerts topic..."
docker exec kafka kafka-topics --bootstrap-server localhost:9092 \
    --create --topic realtime_alerts \
    --partitions 3 --replication-factor 1 \
    --if-not-exists

echo ""
echo "============================================================================"
echo " Topics Created!"
echo "============================================================================"
echo ""
echo "Topics:"
echo "  - tweets_topic (3 partitions)"
echo "  - realtime_alerts (3 partitions)"
echo ""



