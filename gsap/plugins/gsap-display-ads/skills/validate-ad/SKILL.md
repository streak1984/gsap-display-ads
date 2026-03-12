---
name: validate-ad
description: Check a display ad for Google Ads compliance. Use when asked to validate, check, or verify an ad.
user-invocable: true
allowed-tools: Read, Bash, Glob, Grep
---

# Validate Display Ad

You are checking a display ad for Google Ads compliance. Run both the automated checker and a manual review.

## Step 1: Identify the Ad

Find the ad to validate. Look in the `output/` directory:

```
output/<ad-name>/<size>/index.html
```

If the user doesn't specify which ad, use `Glob` to list all available ads in `output/` and ask which one to validate. If they want all ads checked, validate each one.

## Step 2: Run Automated Checks

Run the compliance validation script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh output/<ad-name>/<width>x<height>
```

Report the results to the user.

## Step 3: Manual Review

Read the ad's `index.html` and perform these additional checks that the script doesn't cover:

### Animation Compliance
- [ ] Total animation duration ≤ 30 seconds
- [ ] Animation ends on a static frame (no looping after final state)
- [ ] No audio elements
- [ ] No auto-expanding behavior

### clickTag Implementation
- [ ] `var clickTag = "https://www.google.com";` is declared correctly
- [ ] Click handler uses `window.open(clickTag)` — not `window.location` or `href`
- [ ] Click handler is attached to the main container element
- [ ] No other click handlers that navigate away

### HTML Structure
- [ ] `<!DOCTYPE html>` is the first line
- [ ] `<meta charset="utf-8">` is present
- [ ] `<meta name="ad.size">` dimensions match the intended size
- [ ] Body and container dimensions match the meta tag dimensions

### External Resources
- [ ] Only external domain is `s0.2mdn.net` (Google's GSAP CDN)
- [ ] No Google Fonts, external CSS, or third-party scripts
- [ ] No absolute file paths (all paths are relative)
- [ ] All images are local files (no external image URLs)

### CSS
- [ ] Container has `overflow: hidden`
- [ ] Container has a visible border (1px solid)
- [ ] No `position: fixed` elements
- [ ] All elements are contained within the ad dimensions

### Best Practices
- [ ] Ad is a single HTML file with inline CSS/JS (preferred) or uses minimal files
- [ ] File count is well under 40
- [ ] Total size is well under 150KB (with margin for assets the user may add)

## Step 4: Report

Present findings as a clear compliance report:

**Automated checks**: X passed, Y failed
**Manual review**: List any issues found

For each failure, provide:
1. What the issue is
2. Why Google requires it
3. How to fix it (specific code change)

If all checks pass, confirm the ad is ready for Google Ads upload and suggest using `/export-ad` to create the ZIP bundle.
