@echo off
REM ============================================================================
REM Run Spark Batch Job
REM ============================================================================

echo ============================================================================
echo  Running Apache Spark Batch Job
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
set TWEETS_CSV_PATH=data\Tweets.csv
set OUTPUT_PATH=output\batch_results_parquet
set USE_HIVE=false

REM Run Spark job
python scripts\spark_batch_job.py

echo.
echo Results saved to: output\batch_results_parquet
pause

