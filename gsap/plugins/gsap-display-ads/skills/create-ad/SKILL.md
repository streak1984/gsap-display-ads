---
name: create-ad
description: Generate a Google Display Ad with GSAP animations from a natural language description. Use when asked to create, make, or build a display ad, banner ad, or HTML5 ad.
user-invocable: true
allowed-tools: Read, Write, Bash, Glob, Grep, Edit
---

# Create Display Ad

You are generating a Google Display Ad with GSAP animations. Follow the compliance rules in `${CLAUDE_PLUGIN_ROOT}/CLAUDE.md` exactly — Google will reject non-compliant creatives.

## Step 1: Resolve Brand Profile

Check for existing brand profiles:

1. Use `Glob` to list files in `${CLAUDE_PLUGIN_ROOT}/brands/*.json`
2. **If profiles exist:**
   - If only one profile exists, confirm with the user: "I found the **[brand name]** brand profile. Should I use it?"
   - If multiple profiles exist, ask: "Which brand should I use?" and list the available profiles by name
   - Load the selected `brands/<slug>.json` and use **all values from it** as the primary styling source
3. **If no profiles exist:**
   - Tell the user: "No brand profiles found. I can create one now with `/setup-brand`, or you can provide brand details manually for this ad."
   - If they choose manual, gather brand name, colors, CTA style, and font preferences directly

## Step 2: Gather Campaign-Specific Details

The brand profile handles all styling. Only ask for what's specific to this campaign (if not already provided):

- **Headline** — main message (required)
- **Subheadline** — supporting text (optional)
- **CTA text** — call-to-action button text (default: brand profile's `cta.defaultText`)
- **Target sizes** — which ad dimensions to generate (default: 300x250)
- **Animation style** — subtle, moderate, or energetic (default: brand profile's `animation.defaultStyle`)

Do **not** ask for colors, fonts, CTA styling, or logo details — these come from the brand profile.

## Step 3: Read the Reference Template

Read the reference template to understand the required HTML structure:

```
${CLAUDE_PLUGIN_ROOT}/templates/base.html
```

Also read the brand profile's `rules.dos` and `rules.donts` arrays and follow them as generation guardrails.

## Step 4: Generate the Ad

Create a single `index.html` file with **all CSS and JavaScript inline**. The file must include:

### HTML Structure
- `<!DOCTYPE html>` declaration
- `<meta charset="utf-8">`
- `<meta name="ad.size" content="width=WIDTH,height=HEIGHT">`
- `<!-- brand: <slug> -->` comment immediately after the opening `<html>` tag (for traceability)
- A container `<div id="ad-container">` that is the click target
- All visual elements as child divs with descriptive class names

### CSS (inline in `<style>`) — Map Directly from Brand Profile

Use the brand profile values for every styling decision. Follow this explicit mapping:

```
#ad-container background   → brand.colors.background (or gradient with brand.colors.secondary)
.headline color            → brand.colors.text
.headline font-weight      → brand.typography.headlineWeight
.headline text-transform   → brand.typography.headlineTransform
.subheadline color         → brand.colors.textSecondary
.subheadline font-weight   → brand.typography.bodyWeight
.cta background            → brand.colors.cta
.cta color                 → brand.colors.ctaText
.cta border-radius         → brand.cta.borderRadius
.cta text-transform        → brand.cta.textTransform
.cta letter-spacing        → brand.cta.letterSpacing
.logo color                → brand.colors.primary (if logo.type = "text")
font-family (all elements) → brand.typography.fontFamily
```

Additional CSS requirements:
- Reset: `* { margin: 0; padding: 0; box-sizing: border-box; }`
- Body sized exactly to ad dimensions, `overflow: hidden`
- Container: `position: relative`, exact ad dimensions, `overflow: hidden`, `border: 1px solid #ccc`, `cursor: pointer`
- All elements use `position: absolute` for precise placement
- Animated elements start with `opacity: 0` and any initial transform offsets
- Add CSS comments indicating brand profile sources (e.g., `/* Brand: colors.background */`)

### Logo Placement

Map `brand.logo.placement` to absolute positioning:

| Placement | CSS |
|-----------|-----|
| `top-left` | `top: 16px; left: 16px;` |
| `top-right` | `top: 16px; right: 16px;` |
| `top-center` | `top: 16px; left: 50%; transform: translateX(-50%);` |
| `bottom-left` | `bottom: 16px; left: 16px;` |
| `bottom-right` | `bottom: 16px; right: 16px;` |

If `brand.logo.type` is `"text"`, render as a styled `<div>` with the brand name.
If `brand.logo.type` is `"file"`, use an `<img>` tag with `brand.logo.filePath` and `max-height` set to `brand.logo.maxHeightPx`.

### JavaScript
- GSAP loaded from Google CDN: `https://s0.2mdn.net/ads/studio/cached_libs/gsap_3.14.1_min.js`
- clickTag: `var clickTag = "https://www.google.com";`
- Click handler on `#ad-container` using `window.open(clickTag)`
- `gsap.timeline()` with labeled sections:
  - `intro` (0-3s): Logo and background elements fade/slide in
  - `messaging` (3s+): Headline, subheadline, features animate in sequence
  - `endframe` (final): CTA appears and all animation stops — static end frame

### Animation Style Guidelines

**Subtle**: Gentle fades and small slides (10-15px). Use `power1.out` easing. Longer durations (1-1.5s per element).

**Moderate** (default): Mix of fades, slides (15-25px), and subtle scale. Use `power2.out` easing. Medium durations (0.6-1s per element). CTA can use `back.out(1.7)` for a slight pop.

**Energetic**: Larger slides (30-50px), scale effects, rotation. Use `power3.out` or `back.out` easing. Shorter durations (0.4-0.7s). More overlapping animations. CTA can use `elastic.out(1, 0.3)`.

## Step 5: Write the Output

Save the generated ad to:
```
output/<ad-name>/<width>x<height>/index.html
```

Use kebab-case for the ad name derived from the brand name or campaign (e.g., `acme-spring-sale`).

## Step 6: Validate

Run both the Google compliance checker and the brand compliance checker:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh output/<ad-name>/<width>x<height>
```

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate-brand.sh output/<ad-name>/<width>x<height> ${CLAUDE_PLUGIN_ROOT}/brands/<slug>.json
```

If any checks fail, fix the issues and re-validate.

## Step 7: Next Steps

After successful creation, suggest:

1. **Preview**: The user can open the HTML file in a browser to see the animation
2. **Resize**: Offer to create additional sizes with `/resize-ad`
3. **Export**: Offer to bundle as a ZIP with `/export-ad`
4. **Validate**: If they want a detailed compliance report, suggest `/validate-ad`
