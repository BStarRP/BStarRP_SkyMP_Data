# Community Shaders - Settings Override System

The Settings Override System allows mods to provide custom configuration overrides for Community Shaders features without modifying the main settings file. This enables better mod compatibility and allows multiple mods to adjust different settings independently.

## Directory Structure

Override files should be placed in:

```
Data\SKSE\Plugins\CommunityShaders\Overrides\
```

**Per-weather presets** (optional) go next to that folder, one JSON per weather **Editor ID**:

```
Data\SKSE\Plugins\CommunityShaders\Weathers\
```

Each file is named `{EditorID}.json` (for example `SkyrimStormRain.json`) and uses a `featureSettings` object. Features must expose weather variables (for example **LinearLighting**, **Skylighting**, **ExponentialHeightFog**, **ImageBasedLighting**). Enable a block with `"__enabled": true`. Use the in-game **Weather Editor** to confirm Editor IDs and to tune values.

### Interior-only tuning (`SceneSettings/InteriorOnly/`)

Shipped overwrite JSON files apply **only while you are in an interior cell**. Each file sets **one** feature field (Community Shaders merges them at load). Filenames end with `_{FeatureShortName}.json` (for example `WarmInt01_LinearLighting.json`). The repo includes a **WarmInt\*** set aimed at warm, localized lights and **dark corners** (lower ambient, stronger point lights and VL, reduced GI strength and IBL sky fill). Adjust or remove individual files to taste.

### Repo preset tiers: `CustomLook_*`, `QualityPlus_*`, `LowAssist_*`

These three prefixes are meant for **multiplayer / many actors** (default favors FPS while staying attractive), **optional max quality**, and **emergency low-FPS** toggles.

**Important:** If two overrides touch the **same feature** (same `{FeatureShortName}`) and both are **enabled**, Community Shaders **merges** them in discovery order and values can fight. For predictable results: for each feature, keep **only one** of `CustomLook_`, `QualityPlus_`, or `LowAssist_` enabled, **or** only stack `LowAssist_` pieces you understand.

#### Tier 1 - Default: `CustomLook_*` (`enabled`: true)

Use this for **normal play** (including busy towns / MP-style crowds):

-   **LinearLighting / Skylighting / ExponentialHeightFog** — dark, torch-forward nights, moon haze, low skylight floor.
-   **ScreenSpaceGI** — **AO only** (`EnableGI`: false), **quarter res**, light slice/step count (no SSGI bounce; best FPS with many actors).
-   **ImageBasedLighting** — **IBL off** (`EnableIBL`: 0) for maximum GPU headroom with crowds; ambient comes from vanilla + your other lighting. Use **`QualityPlus_ImageBasedLighting.json`** when you want IBL back.
-   **VolumetricLighting** — **Medium** interior + exterior.
-   **DynamicCubemaps** — **SSR off** on water.
-   **SubsurfaceScattering** — **10** Burley samples.

#### Tier 2 - Extra quality: `QualityPlus_*` (`enabled`: false until you turn them on)

Enable in **Overrides** when you want **solo / screenshots / max eye candy**. For each file you enable, **disable** the matching **`CustomLook_{SameFeature}.json`** so settings are not merged twice.

-   **`QualityPlus_ScreenSpaceGI.json`** — `EnableGI`: true, half res, fuller slices/steps/temporal.
-   **`QualityPlus_ImageBasedLighting.json`** — full IBL scales.
-   **`QualityPlus_VolumetricLighting.json`** — **High** VL.
-   **`QualityPlus_DynamicCubemaps.json`** — water **SSR on**.
-   **`QualityPlus_SubsurfaceScattering.json`** — **16** Burley samples.
-   **`QualityPlus_ScreenSpaceShadows.json`** — contact shadows, **SampleCount** 2.

#### Tier 3 - Low assist: `LowAssist_*` (`enabled`: false until you turn them on)

Extra cuts when Tier 1 is not enough (stutter towns, huge PvP crowds):

-   **`LowAssist_VolumetricLighting.json`** — VL **Low**.
-   **`LowAssist_ScreenSpaceShadows.json`** — contact shadows **off**.
-   **`LowAssist_SubsurfaceScattering.json`** — Burley **8** samples.
-   **`LowAssist_ScreenSpaceGI.json`** — explicit AO-only quarter-res block (redundant with default; use if you changed SSGI in menu).
-   **`LowAssist_ImageBasedLighting.json`** — forces **IBL off** if you enabled IBL in menu or used QualityPlus and need to claw back FPS.
-   **`LowAssist_DynamicCubemaps.json`** / **`LowAssist_Global.json`** — SSR off / compiler thread cap.

Try **VL** first, then **contact shadows**, then **SSS**. Default already has **IBL off**.

Weather JSON keys for EH fog use the **display names** registered in CS (for example `"Fog Density"`, `"Directional Inscattering Multiplier"`). Overrides use the feature’s **settings field names** (for example `fogDensity`, `inscatteringTint`).

If **clear daytime** feels too dim, raise **`ambientMult`** / **`directionalLightMult`** in the Linear Lighting menu or add `Weathers/{EditorID}.json` (confirm IDs in the **Weather Editor**). Restart after toggling overrides.

## File Naming Convention

Override files must follow these naming patterns:

### Feature-Specific Overrides

```
{ModName}_{FeatureShortName}.json
```

Examples:

-   `MyMod_Skylighting.json` - Overrides for Skylighting feature
-   `EnhancedSSGI_ScreenSpaceGI.json` - Overrides for Screen Space GI feature
-   `WaterTweaks_WaterEffects.json` - Overrides for Water Effects feature

### Global Overrides

```
{ModName}_Global.json
```

Examples:

-   `PerformanceOptimizer_Global.json` - Global settings changes
-   `MyMod_Global.json` - Global configuration overrides

## File Format

Override files use JSON format and should contain only the settings you want to override, not the complete feature configuration.

### Feature Override Example

```json
{
    "MaxZenith": 2.0,
    "MinDiffuseVisibility": 0.15,
    "_metadata": {
        "modName": "Enhanced Skylighting",
        "version": "1.2.0",
        "description": "Optimized Skylighting settings for better performance",
        "enabled": true
    }
}
```

### Global Override Example

```json
{
    "General": {
        "Enable Shaders": true,
        "Enable Async": true
    },
    "Advanced": {
        "Log Level": "info",
        "Compiler Threads": 8
    },
    "_metadata": {
        "modName": "Performance Optimizer",
        "version": "1.0.0",
        "description": "Global settings optimized for performance",
        "enabled": true
    }
}
```

## Metadata Section

The `_metadata` section also required for the system to identify the override. It provides information about the override:

-   `modName`: Display name of your mod
-   `version`: Version of your override file
-   `description`: Description of what the override does
-   `enabled`: Whether the override is enabled by default (optional, defaults to true)

## Feature Short Names

To create feature-specific overrides, you need to use the correct feature short name. The full list of feature short names is:

-   `CloudShadows` - Cloud Shadows
-   `DynamicCubemaps` - Dynamic Cubemaps
-   `ExtendedMaterials` - Extended Materials
-   `GrassCollision` - Grass Collision
-   `GrassLighting` - Grass Lighting
-   `HairSpecular` - Hair Specular
-   `ImageBasedLighting` - Image-Based Lighting (override filename: `ModName_ImageBasedLighting.json`)
-   `ExponentialHeightFog` - Exponential Height Fog
-   `LightLimitFix` - Light Limit Fix
-   `LODBlending` - LOD Blending
-   `InteriorSun` - Interior Sun
-   `InverseSquareLighting` - Inverse Square Lighting
-   `ScreenSpaceGI` - Screen Space Global Illumination
-   `ScreenSpaceShadows` - Screen-Space Shadows
-   `Skylighting` - Skylighting
-   `TerrainVariation` - Terrain Variation
-   `SkySync` - Sky Sync
-   `SubsurfaceScattering` - Subsurface Scattering
-   `TerrainBlending` - Terrain Blending
-   `TerrainHelper` - Terrain Helper
-   `TerrainShadows` - Terrain Shadows
-   `VolumetricLighting` - Volumetric Lighting
-   `VR` - VR
-   `WaterEffects` - Water Effects
-   `PerformanceOverlay` - Performance Overlay
-   `WetnessEffects` - Wetness Effects
-   `ExtendedTranslucency` - Extended Translucency

**This list is not exhaustive. It is current as of 11/08/2025. All Feature Short Names will work.**

## How It Works

1. **Discovery**: Override files are automatically discovered when Community Shaders loads
2. **Priority**: Overrides are applied after the main settings are loaded but before features initialize
3. **Merging**: Override values are merged into the existing settings, overwriting only the specified values
4. **Global vs Feature**: Global overrides affect the main settings structure, while feature-specific overrides only affect individual features

## Managing Overrides

### In-Game UI

-   Navigate to the "Overrides" tab in the Community Shaders menu
-   View all discovered override files
-   Enable/disable individual overrides
-   Refresh to discover new override files
-   View override file contents and metadata

### Enable/Disable System

-   The entire override system can be toggled on/off
-   Individual overrides can be enabled/disabled
-   Changes take effect on next game restart

## Best Practices for Mod Authors

1. **Use descriptive mod names** in your file names
2. **Include metadata** for better user experience
3. **Only override necessary settings** - don't include unchanged values
4. **Test compatibility** with other override mods
5. **Document your overrides** in your mod description
6. **Version your override files** for easier support

## Troubleshooting

### Override Not Applied

-   Check file naming follows the correct pattern
-   Verify JSON syntax is valid
-   Ensure feature short name is correct
-   Check that override system is enabled in the UI
-   Look for errors in the Community Shaders log

### JSON Validation

Use a JSON validator to ensure your override files have valid syntax:

-   No trailing commas
-   Proper quotation marks around strings
-   Balanced brackets and braces

### Log Messages

Community Shaders logs override discovery and application:

-   Check `CommunityShaders.log` for override-related messages
-   Look for "Discovered X override files" and "Applied X override(s)" messages

## Examples

See the included example override files in the `Overrides` directory for reference implementations.
