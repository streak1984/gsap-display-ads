---
name: export-ad
description: Bundle a display ad into a ZIP file ready for Google Ads upload. Use when asked to export, bundle, zip, or package an ad.
user-invocable: true
allowed-tools: Read, Bash, Glob, Grep
---

# Export Display Ad

You are bundling a display ad (or multiple ads) into ZIP files ready for Google Ads upload.

## Step 1: Identify Ads to Export

Find the ad(s) to export. Look in the `output/` directory:

```
output/<ad-name>/<size>/index.html
```

If the user doesn't specify which ad, use `Glob` to list all available ads in `output/` and ask which ones to export. Common requests:

- **"Export everything"** — bundle every size of every ad
- **"Export the 300x250"** — bundle a specific size
- **"Export all sizes of [ad-name]"** — bundle all sizes of a specific ad

## Step 2: Pre-Export Validation

Before bundling, run both compliance checks on each ad to catch issues early.

### Google Compliance

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh output/<ad-name>/<width>x<height>
```

### Brand Compliance

For each ad, detect the brand profile:

1. Read the ad's `index.html` and look for a `<!-- brand: <slug> -->` comment
2. If found, run the brand compliance checker:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate-brand.sh output/<ad-name>/<width>x<height> ${CLAUDE_PLUGIN_ROOT}/brands/<slug>.json
   ```
3. If no brand comment found, skip brand validation for that ad

**Google compliance failures block export** — these must be fixed first.
**Brand compliance failures produce a warning** but do not block export — the user may intentionally want to override brand rules for a specific campaign.

## Step 3: Bundle Each Ad

For each ad size that passes Google compliance, run the bundle script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bundle.sh output/<ad-name>/<width>x<height>
```

This will:
1. Create a ZIP file at `output/<ad-name>/<ad-name>-<width>x<height>.zip`
2. Check file count (must be ≤ 40)
3. Check ZIP size (must be ≤ 150KB)
4. Report pass/fail

## Step 4: Handle Failures

If a bundle fails the size check:

1. **Check what's taking up space**: List files and their sizes in the ad directory
2. **Suggest optimizations**:
   - Compress images (PNG → optimized PNG, or convert to JPEG/WebP if appropriate)
   - Remove unused assets
   - Minify inline CSS/JS (though usually not needed for single-file ads)
   - If images are small (< 5KB), consider base64 inlining them to reduce file count
3. **Offer to fix**: If the issue is fixable (e.g., images can be optimized), offer to help

## Step 5: Summary

After all bundles are created, provide a summary table:

| Ad | Size | ZIP File | File Size | Google | Brand | Status |
|----|------|----------|-----------|--------|-------|--------|
| acme-sale | 300x250 | output/acme-sale/acme-sale-300x250.zip | 12KB | Pass | Pass | Ready |
| acme-sale | 728x90 | output/acme-sale/acme-sale-728x90.zip | 11KB | Pass | Warn | Ready (with brand warnings) |

Include:
- Total number of ZIPs created
- Any that failed and why
- Brand compliance warnings (if any)
- Reminder that these ZIPs can be uploaded directly to Google Ads (Campaign Manager, Display & Video 360, or Google Ads)

## Upload Instructions

After exporting, remind the user:

1. **Google Ads**: Go to Ads & Extensions → New Ad → Upload ad → Select ZIP file
2. **Campaign Manager 360**: Creative → New → Display → Upload creative → Select ZIP
3. **Display & Video 360**: Creatives → New → Display → Upload → Select ZIP

The clickTag URL will be set in the ad platform — the placeholder `https://www.google.com` in the code is replaced automatically by the platform.
