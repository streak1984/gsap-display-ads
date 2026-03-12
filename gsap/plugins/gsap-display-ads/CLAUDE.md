# GSAP Display Ads — Google Ads Compliance Rules

This file is the central source of truth for generating Google Display Ads with GSAP animations. All skills reference these rules. Follow them exactly — Google will reject non-compliant creatives.

---

## Google Display Ad Compliance Rules

### Required HTML Structure

Every ad **must** include these elements:

1. **Ad size meta tag** — must appear in `<head>`:
   ```html
   <meta name="ad.size" content="width=300,height=250">
   ```

2. **clickTag implementation** — must appear exactly like this in a `<script>` block:
   ```javascript
   var clickTag = "https://www.google.com";
   ```
   The click handler must use `window.open(clickTag)`:
   ```javascript
   document.getElementById("ad-container").addEventListener("click", function() {
     window.open(clickTag);
   });
   ```

3. **DOCTYPE and charset**:
   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
     <meta charset="utf-8">
   ```

### File Size and Count Limits

- **Total ZIP size**: ≤ 150 KB (153,600 bytes)
- **Maximum files in ZIP**: 40
- **GSAP loaded from Google CDN does NOT count** toward the 150 KB limit
- All file paths must be **relative** (no absolute paths)
- All files must be **UTF-8** encoded

### Animation Constraints

- **Maximum total duration**: 30 seconds
- **Animation must stop** at 30 seconds — no looping after that
- The ad must end on a **static end frame** (no moving elements) showing the CTA and brand
- **No audio** unless user-initiated
- **No auto-expanding** ads

---

## GSAP on Google CDN

Google hosts GSAP on their CDN at `s0.2mdn.net`. Files loaded from this CDN do **not** count toward the 150 KB file size limit.

### Core Library

```html
<script src="https://s0.2mdn.net/ads/studio/cached_libs/gsap_3.14.1_min.js"></script>
```

### Available GSAP Plugins (all 3.14.1)

Only use these if the ad specifically needs them — the core library is sufficient for most ads:

| Plugin | CDN URL |
|--------|---------|
| Draggable | `https://s0.2mdn.net/ads/studio/cached_libs/draggable_3.14.1_min.js` |
| CustomEase | `https://s0.2mdn.net/ads/studio/cached_libs/customease_3.14.1_min.js` |
| EasePack | `https://s0.2mdn.net/ads/studio/cached_libs/easepack_3.14.1_min.js` |
| DrawSVGPlugin | `https://s0.2mdn.net/ads/studio/cached_libs/drawsvgplugin_3.14.1_min.js` |
| Flip | `https://s0.2mdn.net/ads/studio/cached_libs/flip_3.14.1_min.js` |

---

## Standard Ad Sizes

| Size | Name | Layout Notes |
|------|------|-------------|
| 300×250 | Medium Rectangle | Most versatile. Stacked layout: headline → subheadline → CTA. |
| 728×90 | Leaderboard | Horizontal flow: logo left, text center, CTA right. Limit to 1-2 lines of text. |
| 336×280 | Large Rectangle | Similar to 300×250 but more breathing room. |
| 300×600 | Half Page | Vertical storytelling. Can use more text and larger imagery. |
| 320×100 | Large Mobile Banner | Horizontal like 728×90 but for mobile. Keep text short. |
| 320×50 | Mobile Leaderboard | Minimal: logo + one headline + CTA. Very limited animation. |
| 160×600 | Wide Skyscraper | Tall and narrow. Vertical text flow, stacked elements. |

---

## Animation Structure

Follow this three-act structure for timing:

```
0s ────── 3s ────── 20s ────── 30s
│  Intro  │  Messaging  │  End Frame  │
│  Fade/  │  Headline → │  Static CTA │
│  Slide  │  Subhead →  │  + Logo     │
│  in     │  Features   │  (no motion)│
```

- **Entrance (0–3s)**: Elements fade/slide into view. Brand/logo can appear here.
- **Messaging sequence (3–20s)**: Headline, supporting text, feature callouts animate in sequence.
- **Static end frame (20–30s)**: All animation stops. CTA button and logo remain visible. This is what the user sees if they look at the ad after animations complete.

Use `gsap.timeline()` with labeled sections for clarity:

```javascript
const tl = gsap.timeline();
tl.addLabel("intro")
  .to(".logo", { opacity: 1, duration: 0.8 })
  .addLabel("messaging", 3)
  .to(".headline", { opacity: 1, y: 0, duration: 0.6 }, "messaging")
  .to(".subheadline", { opacity: 1, y: 0, duration: 0.6 }, "messaging+=1")
  .addLabel("endframe", 20)
  .to(".cta", { opacity: 1, scale: 1, duration: 0.5 }, "endframe");
```

---

## Output Conventions

Generated ads are saved to:
```
output/<ad-name>/<width>x<height>/index.html
```

Example:
```
output/acme-spring-sale/300x250/index.html
output/acme-spring-sale/728x90/index.html
```

- Use kebab-case for `<ad-name>`
- Each size gets its own directory with its own `index.html`
- Images go in the same directory as the HTML (e.g., `output/acme-spring-sale/300x250/logo.png`)

---

## Brand Profiles

Brand profiles store all visual identity rules for a brand, ensuring every generated ad is on-brand by default.

- **Location**: `${CLAUDE_PLUGIN_ROOT}/brands/<brand-slug>.json`
- **Schema reference**: `${CLAUDE_PLUGIN_ROOT}/brands/BRAND_SCHEMA.md`

### Usage Priority

When generating or modifying ads, resolve styling values in this order:

1. **Brand profile values** — always the primary source when a profile exists
2. **User overrides** — explicit per-request changes the user asks for
3. **Never use generic defaults** when a brand profile exists (no more "professional blue/white")

### How Each Skill Uses Brand Profiles

| Skill | Behavior |
|-------|----------|
| `/setup-brand` | Creates or updates a brand profile interactively |
| `/create-ad` | Loads the brand profile first, maps all colors/typography/CTA/logo to CSS, embeds `<!-- brand: <slug> -->` comment |
| `/resize-ad` | Treats the brand profile as the authoritative style source (more reliable than parsing source HTML) |
| `/validate-ad` | Runs brand compliance checks alongside Google compliance checks |
| `/export-ad` | Runs both `validate.sh` and `validate-brand.sh` before bundling |

---

## Shell Script References

Scripts are located relative to the plugin root. In skills, use `${CLAUDE_PLUGIN_ROOT}` for portability:

- **Validate (Google compliance)**: `${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh <ad-directory>`
- **Validate (brand compliance)**: `${CLAUDE_PLUGIN_ROOT}/scripts/validate-brand.sh <ad-directory> <brand-profile.json>`
- **Bundle**: `${CLAUDE_PLUGIN_ROOT}/scripts/bundle.sh <ad-directory> [output.zip]`

---

## Single-File Approach

Prefer generating ads as a **single `index.html`** with inline CSS and JavaScript. This approach:

- Keeps file count low (important for the 40-file limit)
- Simplifies the ZIP structure
- Avoids path issues
- Makes the ad self-contained and easy to preview

Only use separate files when the user provides image assets that need to be included.

---

## Common Easing Functions

Use these for natural-feeling animations:

- `power2.out` — smooth deceleration (good default for most entrances)
- `power2.inOut` — smooth acceleration and deceleration (good for transitions)
- `back.out(1.7)` — slight overshoot (good for playful CTAs)
- `elastic.out(1, 0.3)` — bouncy (use sparingly, good for attention-grabbing elements)

---

## External URL Policy

The **only** allowed external domain is `s0.2mdn.net` (Google's CDN for GSAP).

- No Google Fonts — use system fonts or inline `@font-face` with base64-encoded fonts
- No external images — all images must be local files within the ad directory
- No external CSS frameworks — all styles must be inline
- No analytics or tracking scripts
