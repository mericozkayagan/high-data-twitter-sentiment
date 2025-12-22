#!/bin/bash
# ============================================================================
# Environment Setup Script for Mac/Linux
# Twitter Airline Sentiment Analysis
# ============================================================================

echo "============================================================================"
echo " Twitter Sentiment Analysis - Environment Setup"
echo "============================================================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed or not in PATH"
    echo "Please install Python 3.8+ from https://www.python.org/downloads/"
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "[ERROR] Java is not installed or not in PATH"
    echo "Please install Java 11+ from https://adoptium.net/"
    exit 1
fi

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "[WARNING] Maven is not installed. You can still run Python scripts."
    echo "To build Java apps, install Maven from https://maven.apache.org/download.cgi"
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "[WARNING] Docker is not installed."
    echo "To run Kafka easily, install Docker Desktop from https://www.docker.com/products/docker-desktop"
fi

echo ""
echo "[1/3] Creating Python virtual environment..."
cd "$(dirname "$0")/.."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

echo "[2/3] Activating virtual environment and installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "[3/3] Creating data and output directories..."
mkdir -p data
mkdir -p output
mkdir -p logs

echo ""
echo "============================================================================"
echo " Setup Complete!"
echo "============================================================================"
echo ""
echo "Next steps:"
echo "  1. Download Tweets.csv from Kaggle and place it in the 'data' folder"
echo "  2. Start Kafka: run './scripts/start_kafka.sh' or 'docker-compose up -d'"
echo "  3. Run producer: run './scripts/run_producer.sh'"
echo "  4. Run Spark job: run './scripts/run_spark_job.sh'"
echo "  5. Run Kafka Streams: run './scripts/run_streams_app.sh'"
echo ""

