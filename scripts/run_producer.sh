#!/bin/bash
# ============================================================================
# Run Kafka Producer
# ============================================================================

echo "============================================================================"
echo " Running Kafka Producer"
echo "============================================================================"
echo ""

cd "$(dirname "$0")/.."

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Check if Tweets.csv exists
if [ ! -f "data/Tweets.csv" ]; then
    echo "[ERROR] Tweets.csv not found in data/ directory!"
    echo "Please download it from: https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment"
    exit 1
fi

# Set Kafka bootstrap servers
export KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS:-localhost:9092}

echo "Starting producer..."
echo "Press Ctrl+C to stop."
echo ""

python3 scripts/kafka_producer.py

