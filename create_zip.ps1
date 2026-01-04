# ============================================================================
# Create ZIP file for project submission (excluding large files)
# ============================================================================

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$zipName = "high-data-twitter-sentiment-submission.zip"
$zipPath = Join-Path $projectRoot $zipName

Write-Host "============================================================================"
Write-Host " Creating Project ZIP File"
Write-Host "============================================================================"
Write-Host ""

# Remove existing zip if exists
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Host "Removed existing zip file."
}

Write-Host "Creating zip file: $zipName"
Write-Host "Excluding: venv/, target/, data/Tweets.csv, logs/, output/, .git/"
Write-Host ""

# Change to project root
Push-Location $projectRoot

# Create temporary directory with files to include
$tempDir = Join-Path $env:TEMP "high-data-zip-$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Copy files excluding large directories
$excludeDirs = @("venv", "target", "logs", "output", ".git", ".idea", ".vscode", "__pycache__", "metastore_db", "spark-warehouse", ".docker")
$excludeFiles = @("Tweets.csv", "*.log", "*.pyc", "*.pyo", "*.pyd", ".DS_Store", "Thumbs.db", "dependency-reduced-pom.xml", "*.tmp", "*.temp")

$fileCount = 0
Get-ChildItem -Path . -Recurse -File | Where-Object {
    $relativePath = $_.FullName.Substring($projectRoot.Length + 1)
    $shouldExclude = $false
    
    # Check if file is in excluded directory
    foreach ($dir in $excludeDirs) {
        if ($relativePath -like "*\$dir\*" -or $relativePath -like "$dir\*") {
            $shouldExclude = $true
            break
        }
    }
    
    # Check if file matches excluded pattern
    if (-not $shouldExclude) {
        foreach ($pattern in $excludeFiles) {
            if ($relativePath -like "*\$pattern" -or $relativePath -eq $pattern) {
                $shouldExclude = $true
                break
            }
        }
    }
    
    -not $shouldExclude
} | ForEach-Object {
    $relativePath = $_.FullName.Substring($projectRoot.Length + 1)
    $destPath = Join-Path $tempDir $relativePath
    $destDir = Split-Path $destPath -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item $_.FullName -Destination $destPath -Force
    $fileCount++
    if ($fileCount % 50 -eq 0) {
        Write-Host "  Processed $fileCount files..."
    }
}

# Create zip from temp directory
Write-Host "Compressing files..."
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force

# Cleanup temp directory
Remove-Item $tempDir -Recurse -Force

Pop-Location

$zipSize = (Get-Item $zipPath).Length / 1MB

Write-Host ""
Write-Host "============================================================================"
Write-Host " ZIP File Created Successfully!"
Write-Host "============================================================================"
Write-Host "File: $zipName"
Write-Host "Size: $([math]::Round($zipSize, 2)) MB"
Write-Host "Files included: $fileCount"
Write-Host ""
Write-Host "Note: Tweets.csv is excluded. Please download it separately from:"
Write-Host "https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment"
Write-Host ""
