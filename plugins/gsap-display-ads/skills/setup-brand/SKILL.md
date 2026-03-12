---
name: setup-brand
description: Create or update a brand profile for consistent ad generation. Use when asked to set up a brand, configure brand colors, or create a brand profile.
user-invocable: true
allowed-tools: Read, Write, Bash, Glob, Grep, Edit, WebFetch
---

# Set Up Brand Profile

You are creating or updating a brand profile that will be used by all ad generation skills (`/create-ad`, `/resize-ad`, `/validate-ad`, `/export-ad`) to ensure every ad matches the brand's visual identity.

## Step 1: Read the Schema

Read the brand profile schema to understand the required JSON structure:

```
${CLAUDE_PLUGIN_ROOT}/brands/BRAND_SCHEMA.md
```

## Step 2: Check for Existing Profiles

Use `Glob` to list existing brand profiles:

```
${CLAUDE_PLUGIN_ROOT}/brands/*.json
```

- If a profile already exists for the brand the user mentions, offer to **update** it rather than creating a new one. Show the current values and ask what they'd like to change.
- If no profiles exist, proceed with creating a new one.

## Step 3: Gather Brand Information

Use **one** of the two input modes below, depending on what the user provides.

### Mode A — Manual Questions (always available)

Ask the user for the following. Accept partial answers and fill in sensible defaults for anything they skip:

1. **Brand name** (required) — "What is the brand name?"
2. **Brand colors** — "What are your primary and secondary brand colors? (hex codes like #e94560)"
   - Also ask about background, text, and CTA colors if not obvious from the primary/secondary
3. **CTA button style** — "What should the CTA button look like? (color, shape, default text like 'Shop Now')"
4. **Typography** — "What font family should I use? (must be system fonts: Arial, Helvetica, Georgia, etc.)"
5. **Logo** — "Do you have a logo file, or should I use text-based logo with the brand name?"
6. **Brand rules** — "Any brand rules I should always follow? (do's and don'ts)"

### Mode B — URL/Document Extraction (if user provides a URL or file path)

1. If the user provides a brand guide URL, use `WebFetch` to retrieve it
2. If the user provides a local file path (PDF, image, etc.), use `Read` to examine it
3. Extract all relevant brand values (colors, fonts, CTA style, logo, rules)
4. Present the extracted values to the user for confirmation
5. Let them correct anything that was misread or missing

## Step 4: Build the Profile JSON

Construct the brand profile JSON following the schema exactly. Key rules:

- **`slug`**: Derive from the brand name using kebab-case (e.g., "ACME Corporation" → `"acme-corporation"`)
- **`created`/`updated`**: Use today's date in ISO format (YYYY-MM-DD)
- **`colors`**: All values must be hex codes (e.g., `"#e94560"`, not `"red"`)
- **`typography.fontFamily`**: Must be system fonts only (Arial, Helvetica, Georgia, etc.) — no Google Fonts allowed in display ads
- **`logo.type`**: Use `"text"` if no logo file provided, `"file"` if the user has an image
- **`rules.dos`/`rules.donts`**: Keep these specific and actionable — they guide Claude during ad generation

For any values the user didn't specify, use these defaults:

| Field | Default |
|-------|---------|
| `colors.textSecondary` | A muted version of `colors.text` |
| `colors.cta` | Same as `colors.primary` |
| `colors.ctaText` | `"#ffffff"` |
| `typography.headlineWeight` | `"bold"` |
| `typography.headlineTransform` | `"none"` |
| `typography.bodyWeight` | `"normal"` |
| `cta.defaultText` | `"Learn More"` |
| `cta.shape` | `"rounded"` |
| `cta.borderRadius` | `"4px"` |
| `cta.textTransform` | `"uppercase"` |
| `cta.letterSpacing` | `"1px"` |
| `logo.placement` | `"top-left"` |
| `logo.maxHeightPx` | `40` |
| `animation.defaultStyle` | `"moderate"` |

## Step 5: Write the Profile

Save the JSON to:

```
${CLAUDE_PLUGIN_ROOT}/brands/<slug>.json
```

If updating an existing profile, update the `"updated"` date and preserve the original `"created"` date.

## Step 6: Confirm

Tell the user:

> Brand profile saved to `brands/<slug>.json`.
>
> You can now use `/create-ad` and I'll automatically use this brand's colors, typography, CTA style, and logo. No more generic defaults.
>
> To update this profile later, just run `/setup-brand` again.

Show a summary of the key values that were saved (colors, font, CTA style, logo type).
