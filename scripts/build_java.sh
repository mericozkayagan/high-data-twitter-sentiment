#!/bin/bash
# ============================================================================
# Build Java Application with Maven
# ============================================================================

echo "============================================================================"
echo " Building Java Application"
echo "============================================================================"
echo ""

cd "$(dirname "$0")/.."

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "[ERROR] Maven is not installed!"
    echo "Please install Maven from https://maven.apache.org/download.cgi"
    exit 1
fi

echo "Building with Maven..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo ""
    echo "============================================================================"
    echo " Build Successful!"
    echo "============================================================================"
    echo ""
    echo "JAR file: target/twitter-sentiment-analysis-1.0.0.jar"
else
    echo ""
    echo "[ERROR] Build failed!"
    exit 1
fi

