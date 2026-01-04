#!/bin/bash
# ============================================================================
# Create ZIP file for project submission (excluding large files)
# ============================================================================

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ZIP_NAME="high-data-twitter-sentiment-submission.zip"
ZIP_PATH="$PROJECT_ROOT/$ZIP_NAME"

echo "============================================================================"
echo " Creating Project ZIP File"
echo "============================================================================"
echo ""

# Remove existing zip if exists
if [ -f "$ZIP_PATH" ]; then
    rm "$ZIP_PATH"
    echo "Removed existing zip file."
fi

echo "Creating zip file: $ZIP_NAME"
echo "Excluding: venv/, target/, data/Tweets.csv, logs/, output/, .git/"
echo ""

cd "$PROJECT_ROOT"

# Create zip excluding large directories
zip -r "$ZIP_NAME" . \
    -x "venv/*" \
    -x "target/*" \
    -x "data/Tweets.csv" \
    -x "logs/*" \
    -x "output/*" \
    -x ".git/*" \
    -x ".idea/*" \
    -x ".vscode/*" \
    -x "__pycache__/*" \
    -x "*.pyc" \
    -x "*.pyo" \
    -x "*.pyd" \
    -x ".DS_Store" \
    -x "Thumbs.db" \
    -x "*.log" \
    -x "metastore_db/*" \
    -x "spark-warehouse/*" \
    -x "derby.log" \
    -x ".docker/*" \
    -x "*.tmp" \
    -x "*.temp" \
    -x "dependency-reduced-pom.xml" \
    > /dev/null

ZIP_SIZE=$(du -h "$ZIP_PATH" | cut -f1)
FILE_COUNT=$(unzip -l "$ZIP_PATH" | tail -1 | awk '{print $2}')

echo ""
echo "============================================================================"
echo " ZIP File Created Successfully!"
echo "============================================================================"
echo "File: $ZIP_NAME"
echo "Size: $ZIP_SIZE"
echo "Files included: $FILE_COUNT"
echo ""
echo "Note: Tweets.csv is excluded. Please download it separately from:"
echo "https://www.kaggle.com/datasets/crowdflower/twitter-airline-sentiment"
echo ""
