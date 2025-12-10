@echo off
REM ============================================================================
REM Start Kafka using Docker Compose
REM ============================================================================

echo ============================================================================
echo  Starting Kafka Environment (Docker)
echo ============================================================================
echo.

cd /d "%~dp0\.."

REM Check if Docker is running
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

echo Starting Zookeeper, Kafka, Schema Registry, and Kafka UI...
docker-compose up -d

echo.
echo Waiting for services to start...
timeout /t 10 /nobreak

echo.
echo ============================================================================
echo  Services Started!
echo ============================================================================
echo.
echo   Kafka:           localhost:9092
echo   Schema Registry: localhost:8081
echo   Kafka UI:        http://localhost:8080
echo.
echo To stop services: docker-compose down
echo.
pause

