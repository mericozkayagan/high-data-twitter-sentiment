@echo off
REM ============================================================================
REM Run Kafka Producer Script
REM ============================================================================

echo ============================================================================
echo  Running Kafka Producer
echo ============================================================================
echo.

cd /d "%~dp0\.."

REM Check if data file exists
if not exist "data\Tweets.csv" (
    echo [ERROR] Tweets.csv not found in data folder!
    echo.
    echo Please download the dataset from:
    echo https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment
    echo.
    echo And place Tweets.csv in the 'data' folder.
    pause
    exit /b 1
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Set environment variables
set KAFKA_BOOTSTRAP_SERVERS=localhost:9092
set TWEETS_CSV_PATH=data\Tweets.csv

REM Run producer
python scripts\kafka_producer.py

pause

