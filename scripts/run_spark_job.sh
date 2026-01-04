#!/bin/bash
# ============================================================================
# Run Spark Batch Job
# ============================================================================

echo "============================================================================"
echo " Running Spark Batch Job"
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

echo "Starting Spark batch job..."
echo ""

python3 scripts/spark_batch_job.py



