---
name: validate-ad
description: Check a display ad for Google Ads compliance. Use when asked to validate, check, or verify an ad.
user-invocable: true
allowed-tools: Read, Bash, Glob, Grep
---

# Validate Display Ad

You are checking a display ad for Google Ads compliance **and** brand compliance. Run the automated checkers and a manual review.

## Step 1: Identify the Ad

Find the ad to validate. Look in the `output/` directory:

```
output/<ad-name>/<size>/index.html
```

If the user doesn't specify which ad, use `Glob` to list all available ads in `output/` and ask which one to validate. If they want all ads checked, validate each one.

## Step 2: Run Automated Google Compliance Checks

Run the compliance validation script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh output/<ad-name>/<width>x<height>
```

Report the results to the user.

## Step 3: Run Brand Compliance Checks

Detect the brand profile to use:

1. Read the ad's `index.html` and look for a `<!-- brand: <slug> -->` comment
2. If found, load `${CLAUDE_PLUGIN_ROOT}/brands/<slug>.json`
3. If not found, check `${CLAUDE_PLUGIN_ROOT}/brands/*.json` — if only one profile exists, ask the user to confirm; if multiple exist, ask which brand this ad belongs to
4. If no brand profiles exist, skip brand validation and note that no brand profile was available

If a brand profile is available, run the brand compliance checker:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate-brand.sh output/<ad-name>/<width>x<height> ${CLAUDE_PLUGIN_ROOT}/brands/<slug>.json
```

## Step 4: Manual Review

Read the ad's `index.html` and perform these additional checks that the scripts don't cover:

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

### Brand Compliance (if brand profile loaded)
- [ ] Background color matches `brand.colors.background`
- [ ] Headline color matches `brand.colors.text`
- [ ] CTA button background matches `brand.colors.cta`
- [ ] CTA button text color matches `brand.colors.ctaText`
- [ ] CTA border-radius matches `brand.cta.borderRadius`
- [ ] Font family matches `brand.typography.fontFamily`
- [ ] Logo is present and correctly placed per `brand.logo.placement`
- [ ] No off-brand colors used (all hex values trace back to the brand palette)
- [ ] `rules.dos` are followed
- [ ] `rules.donts` are not violated

## Step 5: Report

Present findings as a clear compliance report:

**Google Ads automated checks**: X passed, Y failed
**Brand compliance checks**: X passed, Y failed, Z warnings
**Manual review**: List any issues found

For each failure, provide:
1. What the issue is
2. Why it matters (Google rejection risk or brand violation)
3. How to fix it (specific code change)

If all checks pass, confirm the ad is ready for Google Ads upload and suggest using `/export-ad` to create the ZIP bundle.
