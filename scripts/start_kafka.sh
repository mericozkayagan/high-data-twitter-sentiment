#!/bin/bash
# ============================================================================
# Start Kafka Environment (Docker)
# ============================================================================

echo "============================================================================"
echo " Starting Kafka Environment"
echo "============================================================================"
echo ""

cd "$(dirname "$0")/.."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "[ERROR] Docker is not running!"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo "Starting Docker containers..."
docker-compose up -d

echo ""
echo "Waiting for services to start..."
sleep 10

echo ""
echo "============================================================================"
echo " Kafka Environment Started!"
echo "============================================================================"
echo ""
echo "Services:"
echo "  - Kafka: localhost:9092"
echo "  - Zookeeper: localhost:2181"
echo "  - Schema Registry: localhost:8081"
echo "  - Kafka UI: http://localhost:8080"
echo ""
echo "To stop: docker-compose down"
echo ""

