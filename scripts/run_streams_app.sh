#!/bin/bash
# ============================================================================
# Run Kafka Streams Application
# ============================================================================

echo "============================================================================"
echo " Running Kafka Streams - Sentiment Alert Application"
echo "============================================================================"
echo ""

cd "$(dirname "$0")/.."

# Check if JAR exists, if not build it
if [ ! -f "target/twitter-sentiment-analysis-1.0.0.jar" ]; then
    echo "Building Java application..."
    mvn clean package -DskipTests
    if [ $? -ne 0 ]; then
        echo "[ERROR] Maven build failed!"
        exit 1
    fi
fi

# Set environment variables
export KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS:-localhost:9092}

# Run the application
echo ""
echo "Starting Sentiment Alert Application..."
echo "Press Ctrl+C to stop."
echo ""

java -jar target/twitter-sentiment-analysis-1.0.0.jar



