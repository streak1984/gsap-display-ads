#!/bin/bash
# validate-brand.sh — Check a display ad for brand compliance
# Usage: ./scripts/validate-brand.sh <ad-directory> <brand-profile.json>
# Separate from validate.sh: this checks brand compliance, not platform compliance.

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <ad-directory> <brand-profile.json>"
  echo "Example: $0 output/acme-spring-sale/300x250 brands/acme.json"
  exit 1
fi

AD_DIR="$1"
BRAND_FILE="$2"
PASS=0
FAIL=0
WARN=0

pass() {
  echo "  ✓ $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "  ✗ $1"
  FAIL=$((FAIL + 1))
}

warn() {
  echo "  ⚠ $1"
  WARN=$((WARN + 1))
}

# Extract a string value from JSON by key (no jq dependency)
# Handles nested keys by matching the key name anywhere in the file
extract_json_value() {
  local file="$1" key="$2"
  grep "\"$key\"" "$file" | head -1 | sed 's/.*: *"\(.*\)".*/\1/'
}

echo ""
echo "Brand Compliance Check"
echo "─────────────────────────────────────"

# Verify inputs exist
if [ ! -d "$AD_DIR" ]; then
  echo "  ✗ Ad directory does not exist: $AD_DIR"
  exit 1
fi

if [ ! -f "$AD_DIR/index.html" ]; then
  echo "  ✗ index.html not found in $AD_DIR"
  exit 1
fi

if [ ! -f "$BRAND_FILE" ]; then
  echo "  ✗ Brand profile not found: $BRAND_FILE"
  exit 1
fi

HTML_FILE="$AD_DIR/index.html"
BRAND_NAME=$(extract_json_value "$BRAND_FILE" "name")
echo "Ad: $AD_DIR"
echo "Brand: $BRAND_NAME"
echo "─────────────────────────────────────"

# 1. Check primary color is present in CSS
PRIMARY=$(extract_json_value "$BRAND_FILE" "primary")
if [ -n "$PRIMARY" ]; then
  PRIMARY_LOWER=$(echo "$PRIMARY" | tr '[:upper:]' '[:lower:]')
  HTML_LOWER=$(tr '[:upper:]' '[:lower:]' < "$HTML_FILE")
  if echo "$HTML_LOWER" | grep -q "$PRIMARY_LOWER"; then
    pass "Primary color ($PRIMARY) present"
  else
    fail "Primary color ($PRIMARY) not found in ad"
  fi
fi

# 2. Check CTA background matches brand.colors.cta
CTA_COLOR=$(extract_json_value "$BRAND_FILE" "cta")
# Filter to only the color value (from the colors section, not the cta object)
CTA_BG=$(grep '"cta"' "$BRAND_FILE" | grep '#' | head -1 | sed 's/.*: *"\(#[a-fA-F0-9]*\)".*/\1/')
if [ -n "$CTA_BG" ]; then
  CTA_BG_LOWER=$(echo "$CTA_BG" | tr '[:upper:]' '[:lower:]')
  # Look for this color near a .cta selector or in CTA-related CSS
  if echo "$HTML_LOWER" | grep -q "$CTA_BG_LOWER"; then
    pass "CTA background color ($CTA_BG) present"
  else
    fail "CTA background color ($CTA_BG) not found in ad"
  fi
fi

# 3. Check CTA text color matches brand.colors.ctaText
CTA_TEXT=$(extract_json_value "$BRAND_FILE" "ctaText")
if [ -n "$CTA_TEXT" ]; then
  CTA_TEXT_LOWER=$(echo "$CTA_TEXT" | tr '[:upper:]' '[:lower:]')
  if echo "$HTML_LOWER" | grep -q "$CTA_TEXT_LOWER"; then
    pass "CTA text color ($CTA_TEXT) present"
  else
    fail "CTA text color ($CTA_TEXT) not found in ad"
  fi
fi

# 4. Check CTA border-radius matches brand.cta.borderRadius
BORDER_RADIUS=$(extract_json_value "$BRAND_FILE" "borderRadius")
if [ -n "$BORDER_RADIUS" ]; then
  if grep -q "$BORDER_RADIUS" "$HTML_FILE"; then
    pass "CTA border-radius ($BORDER_RADIUS) matches"
  else
    fail "CTA border-radius ($BORDER_RADIUS) not found — expected from brand profile"
  fi
fi

# 5. Check font family matches brand.typography.fontFamily
FONT_FAMILY=$(extract_json_value "$BRAND_FILE" "fontFamily")
if [ -n "$FONT_FAMILY" ]; then
  # Extract the first font name for matching (e.g., "Arial" from "Arial, Helvetica, sans-serif")
  FIRST_FONT=$(echo "$FONT_FAMILY" | cut -d',' -f1 | sed 's/^ *//;s/ *$//')
  FIRST_FONT_LOWER=$(echo "$FIRST_FONT" | tr '[:upper:]' '[:lower:]')
  if echo "$HTML_LOWER" | grep -q "$FIRST_FONT_LOWER"; then
    pass "Font family ($FIRST_FONT) present"
  else
    fail "Font family ($FIRST_FONT) not found — expected '$FONT_FAMILY'"
  fi
fi

# 6. Check logo is present
LOGO_TYPE=$(extract_json_value "$BRAND_FILE" "type")
if [ "$LOGO_TYPE" = "text" ]; then
  LOGO_TEXT=$(extract_json_value "$BRAND_FILE" "text")
  if [ -n "$LOGO_TEXT" ]; then
    if grep -q "$LOGO_TEXT" "$HTML_FILE"; then
      pass "Logo text ('$LOGO_TEXT') present"
    else
      fail "Logo text ('$LOGO_TEXT') not found in ad"
    fi
  fi
elif [ "$LOGO_TYPE" = "file" ]; then
  LOGO_PATH=$(extract_json_value "$BRAND_FILE" "filePath")
  if [ -n "$LOGO_PATH" ]; then
    if grep -q "$LOGO_PATH" "$HTML_FILE"; then
      pass "Logo file reference ($LOGO_PATH) present"
    else
      fail "Logo file reference ($LOGO_PATH) not found in ad"
    fi
  fi
fi

# 7. Check for off-brand colors (warn only, don't fail)
# Extract all hex colors from the HTML
AD_COLORS=$(grep -oE '#[a-fA-F0-9]{3,8}' "$HTML_FILE" | tr '[:upper:]' '[:lower:]' | sort -u)

# Extract all hex colors from the brand profile
BRAND_COLORS=$(grep -oE '#[a-fA-F0-9]{3,8}' "$BRAND_FILE" | tr '[:upper:]' '[:lower:]' | sort -u)
# Also include common neutral colors that are always acceptable
BRAND_COLORS=$(printf "%s\n%s" "$BRAND_COLORS" "#ccc #cccccc #000 #000000 #fff #ffffff #333 #333333 #666 #666666 #999 #999999" | tr ' ' '\n' | sort -u)

OFF_BRAND=""
for color in $AD_COLORS; do
  FOUND=0
  for brand_color in $BRAND_COLORS; do
    if [ "$color" = "$brand_color" ]; then
      FOUND=1
      break
    fi
  done
  if [ "$FOUND" -eq 0 ]; then
    OFF_BRAND="$OFF_BRAND $color"
  fi
done

if [ -z "$OFF_BRAND" ]; then
  pass "All colors are on-brand or neutral"
else
  warn "Possible off-brand colors found:$OFF_BRAND"
fi

# Summary
echo ""
echo "─────────────────────────────────────"
echo "Results: $PASS passed, $FAIL failed, $WARN warnings"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "Brand compliance check FAILED"
  exit 1
else
  if [ "$WARN" -gt 0 ]; then
    echo "Brand compliance check PASSED (with warnings)"
  else
    echo "Ad is brand-compliant!"
  fi
  exit 0
fi
