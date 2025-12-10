@echo off
REM ============================================================================
REM Environment Setup Script for Windows
REM Twitter Airline Sentiment Analysis
REM ============================================================================

echo ============================================================================
echo  Twitter Sentiment Analysis - Environment Setup
echo ============================================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Check if Java is installed
java -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Java is not installed or not in PATH
    echo Please install Java 11+ from https://adoptium.net/
    pause
    exit /b 1
)

REM Check if Maven is installed
mvn --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Maven is not installed. You can still run Python scripts.
    echo To build Java apps, install Maven from https://maven.apache.org/download.cgi
)

REM Check if Docker is installed
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Docker is not installed.
    echo To run Kafka easily, install Docker Desktop from https://www.docker.com/products/docker-desktop
)

echo.
echo [1/3] Creating Python virtual environment...
cd /d "%~dp0\.."
if not exist "venv" (
    python -m venv venv
)

echo [2/3] Activating virtual environment and installing dependencies...
call venv\Scripts\activate.bat
pip install --upgrade pip
pip install -r requirements.txt

echo [3/3] Creating data and output directories...
if not exist "data" mkdir data
if not exist "output" mkdir output
if not exist "logs" mkdir logs

echo.
echo ============================================================================
echo  Setup Complete!
echo ============================================================================
echo.
echo Next steps:
echo   1. Download Tweets.csv from Kaggle and place it in the 'data' folder
echo   2. Start Kafka: run 'start_kafka.bat' or 'docker-compose up -d'
echo   3. Run producer: run 'run_producer.bat'
echo   4. Run Spark job: run 'run_spark_job.bat'
echo   5. Run Kafka Streams: run 'run_streams_app.bat'
echo.
pause

