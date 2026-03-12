#!/bin/bash
# bundle.sh — Create a ZIP bundle from an ad directory, ready for Google Ads upload
# Usage: ./scripts/bundle.sh <source-dir> [output.zip]

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <source-dir> [output.zip]"
  echo "Example: $0 output/acme-spring-sale/300x250"
  echo "Example: $0 output/acme-spring-sale/300x250 acme-300x250.zip"
  exit 1
fi

SOURCE_DIR="$1"

# Default output ZIP name: <ad-name>-<size>.zip in the source directory's parent
if [ $# -ge 2 ]; then
  OUTPUT_ZIP="$2"
else
  AD_SIZE=$(basename "$SOURCE_DIR")
  AD_NAME=$(basename "$(dirname "$SOURCE_DIR")")
  OUTPUT_ZIP="$(dirname "$SOURCE_DIR")/${AD_NAME}-${AD_SIZE}.zip"
fi

echo ""
echo "Bundling: $SOURCE_DIR"
echo "Output:   $OUTPUT_ZIP"
echo "─────────────────────────────────────"

# Check source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "✗ Source directory does not exist: $SOURCE_DIR"
  exit 1
fi

# Check index.html exists
if [ ! -f "$SOURCE_DIR/index.html" ]; then
  echo "✗ No index.html found in $SOURCE_DIR"
  exit 1
fi

# Check file count
FILE_COUNT=$(find "$SOURCE_DIR" -type f | wc -l | tr -d ' ')
if [ "$FILE_COUNT" -gt 40 ]; then
  echo "✗ Too many files: $FILE_COUNT (max 40)"
  exit 1
fi
echo "  ✓ File count: $FILE_COUNT / 40"

# Remove existing ZIP if present
if [ -f "$OUTPUT_ZIP" ]; then
  rm "$OUTPUT_ZIP"
fi

# Create ZIP — cd into source dir so paths are relative
(cd "$SOURCE_DIR" && zip -r -q "$(cd - > /dev/null && pwd)/$OUTPUT_ZIP" .)

# Check ZIP was created
if [ ! -f "$OUTPUT_ZIP" ]; then
  echo "✗ Failed to create ZIP"
  exit 1
fi

# Check ZIP size
ZIP_SIZE=$(wc -c < "$OUTPUT_ZIP" | tr -d ' ')
ZIP_SIZE_KB=$((ZIP_SIZE / 1024))
MAX_SIZE=153600

if [ "$ZIP_SIZE" -le "$MAX_SIZE" ]; then
  echo "  ✓ ZIP size: ${ZIP_SIZE_KB}KB / 150KB"
else
  echo "  ✗ ZIP exceeds 150KB limit: ${ZIP_SIZE_KB}KB / 150KB"
  echo ""
  echo "  Optimization suggestions:"
  echo "  - Compress images further (use TinyPNG or similar)"
  echo "  - Remove unused assets"
  echo "  - Simplify CSS/JS"
  echo "  - Consider base64 inlining small images to reduce file count"
  exit 1
fi

echo ""
echo "─────────────────────────────────────"
echo "Bundle created: $OUTPUT_ZIP (${ZIP_SIZE_KB}KB, $FILE_COUNT files)"
echo "Ready for Google Ads upload."
