@echo off
REM ============================================================================
REM Run Kafka Streams Application
REM ============================================================================

echo ============================================================================
echo  Running Kafka Streams - Sentiment Alert Application
echo ============================================================================
echo.

cd /d "%~dp0\.."

REM Check if JAR exists, if not build it
if not exist "target\twitter-sentiment-analysis-1.0.0.jar" (
    echo Building Java application...
    call mvn clean package -DskipTests
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Maven build failed!
        pause
        exit /b 1
    )
)

REM Set environment variables
set KAFKA_BOOTSTRAP_SERVERS=localhost:9092

REM Run the application
echo.
echo Starting Sentiment Alert Application...
echo Press Ctrl+C to stop.
echo.

java -jar target\twitter-sentiment-analysis-1.0.0.jar

pause

