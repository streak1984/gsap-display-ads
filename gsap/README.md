# GSAP Display Ads — Claude Cowork Plugin

Generate Google Ads-compliant HTML5 display ads with GSAP animations from natural language descriptions. Built as a Claude Cowork marketplace plugin.

## Features

- Generate display ads from natural language descriptions
- GSAP animations loaded from Google's CDN (doesn't count toward 150KB limit)
- Automatic compliance validation (clickTag, meta tags, file size, animation duration)
- Resize ads across standard Google Display sizes
- Export as ready-to-upload ZIP bundles

## Installation

1. Open Claude Cowork
2. Go to Plugins → Personal → "Add marketplace from GitHub"
3. Enter `streak1984/gsap-display-ads`
4. Click Sync
5. Install the **gsap-display-ads** plugin from the synced marketplace

## Skills

| Skill | Description |
|-------|-------------|
| `/create-ad` | Generate a new display ad with GSAP animations |
| `/resize-ad` | Adapt an existing ad to new dimensions |
| `/validate-ad` | Check an ad for Google Ads compliance |
| `/export-ad` | Bundle an ad into a ZIP ready for upload |

## Supported Ad Sizes

300×250, 728×90, 336×280, 300×600, 320×100, 320×50, 160×600

## How It Works

1. Describe your ad — brand, colors, headline, CTA
2. Claude generates a single-file HTML5 creative with GSAP animations
3. Validate compliance with Google Ads requirements
4. Export as a ZIP and upload to Google Ads, Campaign Manager 360, or DV360

## License

MIT
