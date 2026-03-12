---
name: create-ad
description: Generate a Google Display Ad with GSAP animations from a natural language description. Use when asked to create, make, or build a display ad, banner ad, or HTML5 ad.
user-invocable: true
allowed-tools: Read, Write, Bash, Glob, Grep, Edit
---

# Create Display Ad

You are generating a Google Display Ad with GSAP animations. Follow the compliance rules in `${CLAUDE_PLUGIN_ROOT}/CLAUDE.md` exactly — Google will reject non-compliant creatives.

## Step 1: Gather Requirements

Ask the user for the following details (if not already provided). You can proceed with reasonable defaults for anything they don't specify:

- **Brand name** — required
- **Brand colors** — primary and secondary (default: use a professional blue/white scheme)
- **Logo** — file path or text-based logo (default: text logo using brand name)
- **Headline** — main message (required)
- **Subheadline** — supporting text (optional)
- **CTA text** — call-to-action button text (default: "Learn More")
- **Target sizes** — which ad dimensions to generate (default: 300x250)
- **Animation style** — subtle, moderate, or energetic (default: moderate)

## Step 2: Read the Reference Template

Read the reference template to understand the required HTML structure:

```
${CLAUDE_PLUGIN_ROOT}/templates/base.html
```

This shows the correct placement of:
- `<meta name="ad.size">` tag
- clickTag variable and click handler
- GSAP CDN script tag
- Timeline structure with labeled sections

## Step 3: Generate the Ad

Create a single `index.html` file with **all CSS and JavaScript inline**. The file must include:

### HTML Structure
- `<!DOCTYPE html>` declaration
- `<meta charset="utf-8">`
- `<meta name="ad.size" content="width=WIDTH,height=HEIGHT">`
- A container `<div id="ad-container">` that is the click target
- All visual elements as child divs with descriptive class names

### CSS (inline in `<style>`)
- Reset: `* { margin: 0; padding: 0; box-sizing: border-box; }`
- Body sized exactly to ad dimensions, `overflow: hidden`
- Container: `position: relative`, exact ad dimensions, `overflow: hidden`, `border: 1px solid #ccc`, `cursor: pointer`
- All elements use `position: absolute` for precise placement
- Animated elements start with `opacity: 0` and any initial transform offsets
- Use system fonts only (Arial, Helvetica, sans-serif) unless the user provides a font file

### JavaScript
- GSAP loaded from Google CDN: `https://s0.2mdn.net/ads/studio/cached_libs/gsap_3.14.1_min.js`
- clickTag: `var clickTag = "https://www.google.com";`
- Click handler on `#ad-container` using `window.open(clickTag)`
- `gsap.timeline()` with labeled sections:
  - `intro` (0–3s): Logo and background elements fade/slide in
  - `messaging` (3s+): Headline, subheadline, features animate in sequence
  - `endframe` (final): CTA appears and all animation stops — static end frame

### Animation Style Guidelines

**Subtle**: Gentle fades and small slides (10-15px). Use `power1.out` easing. Longer durations (1-1.5s per element).

**Moderate** (default): Mix of fades, slides (15-25px), and subtle scale. Use `power2.out` easing. Medium durations (0.6-1s per element). CTA can use `back.out(1.7)` for a slight pop.

**Energetic**: Larger slides (30-50px), scale effects, rotation. Use `power3.out` or `back.out` easing. Shorter durations (0.4-0.7s). More overlapping animations. CTA can use `elastic.out(1, 0.3)`.

## Step 4: Write the Output

Save the generated ad to:
```
output/<ad-name>/<width>x<height>/index.html
```

Use kebab-case for the ad name derived from the brand name or campaign (e.g., `acme-spring-sale`).

## Step 5: Validate

Run the compliance checker:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh output/<ad-name>/<width>x<height>
```

If any checks fail, fix the issues and re-validate.

## Step 6: Next Steps

After successful creation, suggest:

1. **Preview**: The user can open the HTML file in a browser to see the animation
2. **Resize**: Offer to create additional sizes with `/resize-ad`
3. **Export**: Offer to bundle as a ZIP with `/export-ad`
4. **Validate**: If they want a detailed compliance report, suggest `/validate-ad`
