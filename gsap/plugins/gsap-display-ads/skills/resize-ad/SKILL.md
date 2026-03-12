---
name: resize-ad
description: Adapt an existing display ad to new dimensions. Use when asked to resize, adapt, or create additional sizes of an ad.
user-invocable: true
allowed-tools: Read, Write, Bash, Glob, Grep, Edit
---

# Resize Display Ad

You are adapting an existing display ad to new dimensions. This is not a simple scale — each size requires thoughtful layout adjustments.

## Step 1: Identify the Source Ad and Load Brand Profile

Find the existing ad to resize. Look in the `output/` directory:

```
output/<ad-name>/<size>/index.html
```

If the user doesn't specify which ad, use `Glob` to list available ads and ask which one to resize.

**Load the brand profile as the authoritative style source.** The brand profile is more trustworthy than the source HTML, which might have been manually edited with errors:

1. Read the source ad's `index.html` and look for a `<!-- brand: <slug> -->` comment
2. If found, load `${CLAUDE_PLUGIN_ROOT}/brands/<slug>.json` — use this for all color, font, CTA, and logo values
3. If not found, check `${CLAUDE_PLUGIN_ROOT}/brands/*.json` and ask the user which brand to use
4. If no brand profiles exist, fall back to extracting styles from the source HTML

From the source ad, extract the **content** (headline, subheadline, CTA text) and **animation timing**. From the brand profile, use the **styling** (colors, fonts, CTA style, logo).

## Step 2: Determine Target Sizes

Ask the user which sizes they need (if not already specified). Common sizes:

- 300x250 (Medium Rectangle)
- 728x90 (Leaderboard)
- 336x280 (Large Rectangle)
- 300x600 (Half Page)
- 320x100 (Large Mobile Banner)
- 320x50 (Mobile Leaderboard)
- 160x600 (Wide Skyscraper)

## Step 3: Apply Layout Strategy

Each size category requires a different layout approach. Follow these strategies:

### Wide Formats (728x90, 320x100)

- **Layout**: Horizontal flow — logo left, text center, CTA right
- **Typography**: Reduce headline to 1 line max, reduce font sizes
- **Content**: May need to drop subheadline if space is too tight
- **Animation**: Simpler — elements can slide in from left to right in sequence
- **Spacing**: Tight margins (8-12px), elements vertically centered

```
┌─────────────────────────────────────────────────────────┐
│  [LOGO]    Headline Text Here          [CTA Button]     │
└─────────────────────────────────────────────────────────┘
```

### Square Formats (300x250, 336x280)

- **Layout**: Stacked vertical — most flexible format
- **Typography**: Can use larger headline sizes
- **Content**: Room for headline + subheadline + CTA
- **Animation**: Full animation sequence works well here

```
┌──────────────────────┐
│  [LOGO]              │
│                      │
│  Headline Text       │
│  Here                │
│                      │
│  Subheadline text    │
│                      │
│        [CTA Button]  │
└──────────────────────┘
```

### Tall Formats (300x600, 160x600)

- **Layout**: Vertical storytelling with generous spacing
- **Typography**: Can use large text, especially in 300x600
- **Content**: Room for more content — headline, subheadline, features, CTA
- **Animation**: Vertical cascade works well, top to bottom
- **160x600 special**: Very narrow — use short words, stack text vertically, small CTA

```
┌──────────────────────┐     ┌────────┐
│  [LOGO]              │     │ [LOGO] │
│                      │     │        │
│                      │     │ Head-  │
│  Big Headline        │     │ line   │
│  Text Here           │     │        │
│                      │     │ Sub-   │
│  Supporting text     │     │ head   │
│  with more room      │     │        │
│  to breathe          │     │ [CTA]  │
│                      │     │        │
│     [CTA Button]     │     └────────┘
│                      │     160x600
└──────────────────────┘
300x600
```

### Tiny Format (320x50)

- **Layout**: Ultra-minimal — logo + one line + CTA
- **Typography**: Small (11-13px), one line only
- **Content**: Drop subheadline entirely. Shorten headline if needed
- **Animation**: Minimal — a simple fade-in or slide is sufficient. Avoid complex sequences
- **CTA**: Small, compact button or text link style

```
┌──────────────────────────────────────────┐
│  [LOGO]  Short headline    [CTA]        │
└──────────────────────────────────────────┘
```

## Step 4: Generate Each Size

For each target size, create a new `index.html` that:

1. Updates `<meta name="ad.size" content="width=W,height=H">`
2. Includes `<!-- brand: <slug> -->` comment (matching the source ad)
3. Updates `body` and `#ad-container` dimensions
4. Repositions all elements using `position: absolute` with new coordinates
5. Adjusts font sizes proportionally
6. Adjusts animation values (slide distances, durations) to match the new scale
7. Uses all brand profile values for colors, fonts, CTA styling, and logo
8. Includes `/* Brand: ... */` CSS comments indicating which values come from the profile

Save each to: `output/<ad-name>/<width>x<height>/index.html`

Copy any image assets from the source ad to each new size directory.

## Step 5: Validate All Sizes

Run both compliance checkers on each generated size:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh output/<ad-name>/<width>x<height>
```

If a brand profile was loaded, also run:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate-brand.sh output/<ad-name>/<width>x<height> ${CLAUDE_PLUGIN_ROOT}/brands/<slug>.json
```

## Step 6: Summary

After all sizes are generated, provide a summary:
- List all sizes created with their file paths
- Note any content that was shortened or dropped for smaller sizes
- Note brand compliance status for each size
- Suggest `/export-ad` to bundle them for upload
