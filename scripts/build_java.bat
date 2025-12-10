@echo off
REM ============================================================================
REM Build Java Application with Maven
REM ============================================================================

echo ============================================================================
echo  Building Java Application
echo ============================================================================
echo.

cd /d "%~dp0\.."

REM Check if Maven is installed
mvn --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Maven is not installed!
    echo Please install Maven from https://maven.apache.org/download.cgi
    pause
    exit /b 1
)

echo Building with Maven...
mvn clean package -DskipTests

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================================================
    echo  Build Successful!
    echo ============================================================================
    echo.
    echo JAR file: target\twitter-sentiment-analysis-1.0.0.jar
) else (
    echo.
    echo [ERROR] Build failed!
)

pause

