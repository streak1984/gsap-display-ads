# Brand Profile JSON Schema

Brand profiles live at `${CLAUDE_PLUGIN_ROOT}/brands/<brand-slug>.json`. They store all visual identity rules for a brand so that every ad generated with `/create-ad` is on-brand by default.

---

## Full Schema

```json
{
  "slug": "acme",
  "name": "ACME Corporation",
  "created": "2026-03-12",
  "updated": "2026-03-12",

  "colors": {
    "primary": "#e94560",
    "secondary": "#1a1a2e",
    "background": "#16213e",
    "text": "#ffffff",
    "textSecondary": "#a2a2b8",
    "cta": "#e94560",
    "ctaText": "#ffffff"
  },

  "typography": {
    "fontFamily": "Arial, Helvetica, sans-serif",
    "headlineWeight": "bold",
    "headlineTransform": "none",
    "bodyWeight": "normal"
  },

  "cta": {
    "defaultText": "Shop Now",
    "shape": "rounded",
    "borderRadius": "4px",
    "textTransform": "uppercase",
    "letterSpacing": "1px"
  },

  "logo": {
    "type": "text",
    "text": "ACME",
    "filePath": null,
    "placement": "top-left",
    "maxHeightPx": 40
  },

  "animation": {
    "defaultStyle": "moderate"
  },

  "rules": {
    "dos": [
      "Always use the red accent (#e94560) for CTAs",
      "Keep headline text white on dark backgrounds"
    ],
    "donts": [
      "Never use light backgrounds",
      "Never use serif fonts"
    ]
  }
}
```

---

## Field Reference

### Root Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `slug` | string | yes | URL-safe identifier (kebab-case). Used as filename: `<slug>.json` |
| `name` | string | yes | Human-readable brand name |
| `created` | string | yes | ISO date when profile was created |
| `updated` | string | yes | ISO date when profile was last modified |

### `colors`

Semantic color names so skills can map directly without guessing.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `primary` | hex string | yes | Primary brand color — used for accents, logo color |
| `secondary` | hex string | yes | Secondary brand color — used for gradients, backgrounds |
| `background` | hex string | yes | Main ad background color |
| `text` | hex string | yes | Primary text color (headlines) |
| `textSecondary` | hex string | no | Secondary text color (subheadlines, body) |
| `cta` | hex string | yes | CTA button background color |
| `ctaText` | hex string | yes | CTA button text color |

### `typography`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `fontFamily` | string | yes | — | CSS font-family value. Must be system fonts or inline base64 |
| `headlineWeight` | string | no | `"bold"` | CSS font-weight for headlines |
| `headlineTransform` | string | no | `"none"` | CSS text-transform for headlines |
| `bodyWeight` | string | no | `"normal"` | CSS font-weight for body/subheadline text |

### `cta`

Explicit CTA object because CTA styling is the most common brand violation in generated ads.

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `defaultText` | string | yes | — | Default CTA button text (e.g., "Shop Now", "Learn More") |
| `shape` | string | no | `"rounded"` | One of: `"rounded"`, `"pill"`, `"square"` |
| `borderRadius` | string | no | `"4px"` | CSS border-radius value |
| `textTransform` | string | no | `"uppercase"` | CSS text-transform for CTA text |
| `letterSpacing` | string | no | `"1px"` | CSS letter-spacing for CTA text |

### `logo`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | yes | `"text"` or `"file"` — handles the common case where users don't have a logo file |
| `text` | string | if type=text | Text to display as logo (e.g., brand name) |
| `filePath` | string | if type=file | Relative path to logo image file |
| `placement` | string | no | One of: `"top-left"`, `"top-right"`, `"top-center"`, `"bottom-left"`, `"bottom-right"` |
| `maxHeightPx` | number | no | Maximum logo height in pixels (default: 40) |

### `animation`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `defaultStyle` | string | no | `"moderate"` | One of: `"subtle"`, `"moderate"`, `"energetic"` |

### `rules`

Free-text arrays consumed by Claude as generation guardrails — not validated by scripts.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `dos` | string[] | no | Things to always do (e.g., "Always use red accent for CTAs") |
| `donts` | string[] | no | Things to never do (e.g., "Never use light backgrounds") |
