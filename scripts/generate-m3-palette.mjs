#!/usr/bin/env node
// Generate a Material 3 palette folder for the esio-theme.
//
// Usage:
//   node scripts/generate-m3-palette.mjs --seed <hex> --name <slug> [--variant <name>] [--secondary-seed <hex>]
//
// Writes 6 CSS files to themes/esio-theme/assets/css/m3/<slug>/ matching the
// project's selector convention. Uses @material/material-color-utilities with
// the default '2021' spec, so output matches the web Material Theme Builder.
//
// Scheme variants accepted (default TonalSpot):
//   tonal-spot | vibrant | expressive | fidelity | content
//   monochrome | neutral | rainbow | fruit-salad
//
// --secondary-seed <hex> overrides the secondary palette with one derived
// from a second seed (the variant still drives primary/tertiary/neutral
// derivations from the main seed). Mirrors what the web Material Theme
// Builder does when you set a custom Secondary color.
//
// --pin-secondary-fixed-dim writes the secondary-seed hex literally into
// the secondary-fixed-dim token (both light and dark), bypassing M3's
// tone-80 computation. Use when the brand color must appear exactly as
// specified at the fixed-dim slot — e.g., matching a hand-tuned brand
// yellow that M3's algorithm would otherwise normalize.
//
// --secondary-fixed-dim <hex> is the decoupled variant: pin the
// secondary-fixed-dim slot to an arbitrary hex independent of the
// secondary-seed (so secondary itself can derive naturally from the
// primary seed while fixed-dim stays the brand-accent color). Mutually
// exclusive with --pin-secondary-fixed-dim, which sources from the seed.
//
// --harmonize-secondary runs M3's Blend.harmonize on the secondary seed
// before deriving the secondary palette: the seed's hue is nudged a few
// degrees toward the primary seed while chroma and tone are preserved.
// Result: the brand color stays recognizable but reads as "of this
// palette" instead of an unrelated import. Mirrors the harmonization
// step the Material Theme Builder applies to imported custom colors.
// Requires --secondary-seed.

import {
  argbFromHex,
  hexFromArgb,
  Blend,
  Hct,
  SchemeTonalSpot,
  SchemeVibrant,
  SchemeExpressive,
  SchemeFidelity,
  SchemeContent,
  SchemeMonochrome,
  SchemeNeutral,
  SchemeRainbow,
  SchemeFruitSalad,
  DynamicScheme,
  TonalPalette,
  MaterialDynamicColors,
} from "@material/material-color-utilities";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const args = process.argv.slice(2);
let seedHex, name, variantName = "tonal-spot", secondarySeedHex, secondaryFixedDimHex;
let pinSecondaryFixedDim = false;
let harmonizeSecondary = false;
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--seed") seedHex = args[++i];
  else if (args[i] === "--name") name = args[++i];
  else if (args[i] === "--variant") variantName = args[++i];
  else if (args[i] === "--secondary-seed") secondarySeedHex = args[++i];
  else if (args[i] === "--pin-secondary-fixed-dim") pinSecondaryFixedDim = true;
  else if (args[i] === "--secondary-fixed-dim") secondaryFixedDimHex = args[++i];
  else if (args[i] === "--harmonize-secondary") harmonizeSecondary = true;
}
if (!seedHex || !name) {
  console.error("Usage: node scripts/generate-m3-palette.mjs --seed <hex> --name <slug> [--variant tonal-spot|vibrant|expressive|fidelity|content|monochrome|neutral|rainbow|fruit-salad] [--secondary-seed <hex>] [--pin-secondary-fixed-dim] [--secondary-fixed-dim <hex>] [--harmonize-secondary]");
  process.exit(1);
}
if (pinSecondaryFixedDim && !secondarySeedHex) {
  console.error("--pin-secondary-fixed-dim requires --secondary-seed");
  process.exit(1);
}
if (pinSecondaryFixedDim && secondaryFixedDimHex) {
  console.error("--pin-secondary-fixed-dim and --secondary-fixed-dim are mutually exclusive");
  process.exit(1);
}
if (harmonizeSecondary && !secondarySeedHex) {
  console.error("--harmonize-secondary requires --secondary-seed");
  process.exit(1);
}

// Harmonize the secondary seed toward the primary seed before deriving its
// tonal palette. Pinning (--pin-secondary-fixed-dim) and harmonization can
// stack: in that case we pin the *harmonized* hex into the fixed-dim slot
// so the literal value still reads as palette-compatible.
if (harmonizeSecondary) {
  const beforeHex = secondarySeedHex.startsWith("#") ? secondarySeedHex : `#${secondarySeedHex}`;
  const afterArgb = Blend.harmonize(argbFromHex(beforeHex), argbFromHex(seedHex.startsWith("#") ? seedHex : `#${seedHex}`));
  secondarySeedHex = hexFromArgb(afterArgb);
  console.log(`harmonized secondary ${beforeHex} → ${secondarySeedHex} (toward primary ${seedHex})`);
}

const variants = {
  "tonal-spot": SchemeTonalSpot,
  "vibrant": SchemeVibrant,
  "expressive": SchemeExpressive,
  "fidelity": SchemeFidelity,
  "content": SchemeContent,
  "monochrome": SchemeMonochrome,
  "neutral": SchemeNeutral,
  "rainbow": SchemeRainbow,
  "fruit-salad": SchemeFruitSalad,
};
const Scheme = variants[variantName];
if (!Scheme) {
  console.error(`Unknown variant: ${variantName}. Choices: ${Object.keys(variants).join(", ")}`);
  process.exit(1);
}

const parseHct = (hex) => Hct.fromInt(argbFromHex(hex.startsWith("#") ? hex : `#${hex}`));
const hct = parseHct(seedHex);
const secondaryHct = secondarySeedHex ? parseHct(secondarySeedHex) : null;

// Build a scheme honoring --secondary-seed when provided: take the variant's
// own palette derivations as a base, then override only secondaryPalette with
// one derived from the secondary seed's HCT (hue + chroma preserved so the
// brand color reads as itself, not as the variant's auto-muted secondary).
function buildScheme(Scheme, primaryHct, isDark, contrast, secondaryHct) {
  const base = new Scheme(primaryHct, isDark, contrast);
  if (!secondaryHct) return base;
  return new DynamicScheme({
    sourceColorArgb: base.sourceColorArgb,
    variant: base.variant,
    contrastLevel: contrast,
    isDark,
    primaryPalette: base.primaryPalette,
    secondaryPalette: TonalPalette.fromHueAndChroma(secondaryHct.hue, secondaryHct.chroma),
    tertiaryPalette: base.tertiaryPalette,
    neutralPalette: base.neutralPalette,
    neutralVariantPalette: base.neutralVariantPalette,
  });
}

// Tokens in the order they appear in the MTB raw export, so diffs against
// hand-curated palettes stay readable.
const tokens = [
  "primary", "surfaceTint", "onPrimary", "primaryContainer", "onPrimaryContainer",
  "secondary", "onSecondary", "secondaryContainer", "onSecondaryContainer",
  "tertiary", "onTertiary", "tertiaryContainer", "onTertiaryContainer",
  "error", "onError", "errorContainer", "onErrorContainer",
  "background", "onBackground",
  "surface", "onSurface", "surfaceVariant", "onSurfaceVariant",
  "outline", "outlineVariant",
  "shadow", "scrim",
  "inverseSurface", "inverseOnSurface", "inversePrimary",
  "primaryFixed", "onPrimaryFixed", "primaryFixedDim", "onPrimaryFixedVariant",
  "secondaryFixed", "onSecondaryFixed", "secondaryFixedDim", "onSecondaryFixedVariant",
  "tertiaryFixed", "onTertiaryFixed", "tertiaryFixedDim", "onTertiaryFixedVariant",
  "surfaceDim", "surfaceBright",
  "surfaceContainerLowest", "surfaceContainerLow", "surfaceContainer",
  "surfaceContainerHigh", "surfaceContainerHighest",
];

const kebab = (s) => s.replace(/[A-Z]/g, (m) => `-${m.toLowerCase()}`);
const argbToRgb = (argb) => {
  const r = (argb >> 16) & 0xff, g = (argb >> 8) & 0xff, b = argb & 0xff;
  return `rgb(${r} ${g} ${b})`;
};
const argbToHex = (argb) => {
  const r = (argb >> 16) & 0xff, g = (argb >> 8) & 0xff, b = argb & 0xff;
  return "#" + [r, g, b].map((x) => x.toString(16).padStart(2, "0")).join("");
};

// Pins map MCU token names to literal hex strings that should override the
// scheme's computed value. Used by --pin-secondary-fixed-dim and friends.
function buildPins() {
  const pins = {};
  if (pinSecondaryFixedDim) pins.secondaryFixedDim = secondarySeedHex;
  if (secondaryFixedDimHex) pins.secondaryFixedDim = secondaryFixedDimHex;
  return pins;
}
const pins = buildPins();

const rgbFromHex = (hex) => {
  const h = hex.startsWith("#") ? hex.slice(1) : hex;
  const r = parseInt(h.slice(0, 2), 16), g = parseInt(h.slice(2, 4), 16), b = parseInt(h.slice(4, 6), 16);
  return `rgb(${r} ${g} ${b})`;
};

function emit(selector, scheme) {
  const lines = [`${selector} {`];
  for (const token of tokens) {
    const value = token in pins
      ? rgbFromHex(pins[token])
      : argbToRgb(MaterialDynamicColors[token].getArgb(scheme));
    lines.push(`  --md-sys-color-${kebab(token)}: ${value};`);
  }
  lines.push("}", "");
  return lines.join("\n");
}

// Build a JSON object mirroring the CSS tokens — used by the Typst marketing
// renderer (marketing-typst/) which has no CSS parser but reads JSON natively.
// Keys are kebab-case (same as the CSS custom property names without the
// --md-sys-color- prefix) so consumers can write json.primary, json["on-surface"], etc.
function emitJson(scheme) {
  const obj = {};
  for (const token of tokens) {
    obj[kebab(token)] = token in pins
      ? (pins[token].startsWith("#") ? pins[token] : `#${pins[token]}`)
      : argbToHex(MaterialDynamicColors[token].getArgb(scheme));
  }
  return JSON.stringify(obj, null, 2) + "\n";
}

// Match the selector convention used by existing palettes (blue, forest, …):
// the canonical light/dark files are palette-scoped, the contrast variants
// are not (they aren't @imported by the build today, so this matches the
// dormant pattern).
const files = [
  { file: "light.css",    selector: `:root[data-palette="${name}"][data-theme="light"]`, isDark: false, contrast: 0   },
  { file: "dark.css",     selector: `:root[data-palette="${name}"][data-theme="dark"]`,  isDark: true,  contrast: 0   },
  { file: "light-mc.css", selector: `:root[data-theme="light"][data-contrast="medium"]`, isDark: false, contrast: 0.5 },
  { file: "light-hc.css", selector: `:root[data-theme="light"][data-contrast="high"]`,   isDark: false, contrast: 1.0 },
  { file: "dark-mc.css",  selector: `:root[data-theme="dark"][data-contrast="medium"]`,  isDark: true,  contrast: 0.5 },
  { file: "dark-hc.css",  selector: `:root[data-theme="dark"][data-contrast="high"]`,    isDark: true,  contrast: 1.0 },
];

const outDir = path.join(repoRoot, "themes/esio-theme/assets/css/m3", name);
await mkdir(outDir, { recursive: true });

for (const f of files) {
  const scheme = buildScheme(Scheme, hct, f.isDark, f.contrast, secondaryHct);
  await writeFile(path.join(outDir, f.file), emit(f.selector, scheme));
}

// Also emit JSON sidecars for light.css and dark.css so the Typst marketing
// renderer can consume the same tokens without a CSS parser.
const jsonFiles = [
  { file: "light.json", isDark: false, contrast: 0 },
  { file: "dark.json",  isDark: true,  contrast: 0 },
];
for (const f of jsonFiles) {
  const scheme = buildScheme(Scheme, hct, f.isDark, f.contrast, secondaryHct);
  await writeFile(path.join(outDir, f.file), emitJson(scheme));
}

// Report the swatch hex (primary at the light scheme — what the picker chip
// should show). Use this for [[params.m3.options]].swatch in hugo.toml.
const lightScheme = buildScheme(Scheme, hct, false, 0, secondaryHct);
const swatch = argbToHex(MaterialDynamicColors.primary.getArgb(lightScheme));
const pinReport = secondaryFixedDimHex ? ` + secondary-fixed-dim pin ${secondaryFixedDimHex}` : "";
const seedReport = (secondarySeedHex ? `${seedHex} + secondary ${secondarySeedHex}` : seedHex) + pinReport;
console.log(`palette '${name}' (${variantName}) generated from seed ${seedReport}`);
console.log(`  out: themes/esio-theme/assets/css/m3/${name}/`);
console.log(`  picker swatch (use for hugo.toml): ${swatch}`);
