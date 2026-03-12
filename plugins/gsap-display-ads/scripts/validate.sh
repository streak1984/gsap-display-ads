#!/bin/bash
# validate.sh — Check a display ad directory for Google Ads compliance
# Usage: ./scripts/validate.sh <ad-directory>

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <ad-directory>"
  echo "Example: $0 output/acme-spring-sale/300x250"
  exit 1
fi

AD_DIR="$1"
PASS=0
FAIL=0

pass() {
  echo "  ✓ $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "  ✗ $1"
  FAIL=$((FAIL + 1))
}

echo ""
echo "Validating: $AD_DIR"
echo "─────────────────────────────────────"

# 1. Check ad directory exists
if [ ! -d "$AD_DIR" ]; then
  echo "  ✗ Directory does not exist: $AD_DIR"
  exit 1
fi

# 2. Check index.html exists
if [ -f "$AD_DIR/index.html" ]; then
  pass "index.html exists"
else
  fail "index.html not found at root of ad directory"
fi

# 3. Check meta ad.size tag
if grep -q '<meta name="ad.size"' "$AD_DIR/index.html" 2>/dev/null; then
  # Extract dimensions from directory name if possible
  DIR_NAME=$(basename "$AD_DIR")
  if echo "$DIR_NAME" | grep -qE '^[0-9]+x[0-9]+$'; then
    WIDTH=$(echo "$DIR_NAME" | cut -dx -f1)
    HEIGHT=$(echo "$DIR_NAME" | cut -dx -f2)
    if grep -q "content=\"width=${WIDTH},height=${HEIGHT}\"" "$AD_DIR/index.html" 2>/dev/null; then
      pass "ad.size meta tag matches directory name (${WIDTH}x${HEIGHT})"
    else
      fail "ad.size meta tag does not match directory name (expected ${WIDTH}x${HEIGHT})"
    fi
  else
    pass "ad.size meta tag present"
  fi
else
  fail "Missing <meta name=\"ad.size\"> tag in <head>"
fi

# 4. Check clickTag variable
if grep -q 'var clickTag' "$AD_DIR/index.html" 2>/dev/null; then
  pass "clickTag variable declared"
else
  fail "Missing clickTag variable declaration (var clickTag = \"...\";)"
fi

# 5. Check window.open(clickTag)
if grep -q 'window.open(clickTag)' "$AD_DIR/index.html" 2>/dev/null; then
  pass "window.open(clickTag) present"
else
  fail "Missing window.open(clickTag) — required for click handling"
fi

# 6. Check for disallowed external URLs
# Allow only s0.2mdn.net
DISALLOWED=$(grep -oE 'https?://[a-zA-Z0-9.-]+' "$AD_DIR/index.html" 2>/dev/null \
  | grep -v 's0.2mdn.net' \
  | grep -v 'www.google.com' \
  | sort -u || true)

if [ -z "$DISALLOWED" ]; then
  pass "No disallowed external URLs"
else
  fail "Disallowed external URLs found:"
  echo "$DISALLOWED" | while read -r url; do
    echo "        → $url"
  done
fi

# 7. Check file count (max 40)
FILE_COUNT=$(find "$AD_DIR" -type f | wc -l | tr -d ' ')
if [ "$FILE_COUNT" -le 40 ]; then
  pass "File count: $FILE_COUNT / 40"
else
  fail "File count exceeds limit: $FILE_COUNT / 40"
fi

# 8. Check directory size (max 150KB = 153600 bytes)
# Exclude GSAP CDN files since they don't count — only local files matter
DIR_SIZE=$(find "$AD_DIR" -type f -exec cat {} + 2>/dev/null | wc -c | tr -d ' ')
DIR_SIZE_KB=$((DIR_SIZE / 1024))
if [ "$DIR_SIZE" -le 153600 ]; then
  pass "Directory size: ${DIR_SIZE_KB}KB / 150KB"
else
  fail "Directory size exceeds 150KB limit: ${DIR_SIZE_KB}KB / 150KB"
fi

# 9. Check for DOCTYPE
if head -1 "$AD_DIR/index.html" 2>/dev/null | grep -qi 'doctype'; then
  pass "DOCTYPE declaration present"
else
  fail "Missing <!DOCTYPE html> declaration"
fi

# 10. Check for charset
if grep -q '<meta charset' "$AD_DIR/index.html" 2>/dev/null; then
  pass "charset meta tag present"
else
  fail "Missing <meta charset=\"utf-8\"> tag"
fi

# Summary
echo ""
echo "─────────────────────────────────────"
echo "Results: $PASS passed, $FAIL failed"
echo ""

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  echo "Ad is Google Ads compliant!"
  exit 0
fi
