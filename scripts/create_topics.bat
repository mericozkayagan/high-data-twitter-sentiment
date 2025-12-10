@echo off
REM ============================================================================
REM Create Kafka Topics
REM ============================================================================

echo ============================================================================
echo  Creating Kafka Topics
echo ============================================================================
echo.

REM Create tweets_topic
echo Creating topic: tweets_topic
docker exec kafka kafka-topics --create --topic tweets_topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 --if-not-exists

REM Create realtime_alerts topic
echo Creating topic: realtime_alerts
docker exec kafka kafka-topics --create --topic realtime_alerts --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 --if-not-exists

echo.
echo Listing all topics:
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

echo.
echo Topics created successfully!
pause

