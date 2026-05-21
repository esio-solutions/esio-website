#!/usr/bin/env node
// Generate the 5 M3 tonal palettes (Primary, Secondary, Tertiary, Neutral,
// Neutral-Variant) as tone strips for a given seed + variant.
//
// Usage:
//   node scripts/generate-m3-tonal-palettes.mjs --seed <hex> --name <slug> [--variant <name>] [--secondary-seed <hex>]
//
// Writes `tones.css` and `tones.json` into
// themes/esio-theme/assets/css/m3/<slug>/ — sitting next to the role-based
// light.css/dark.css produced by generate-m3-palette.mjs.
//
// CSS tokens follow the M3 ref-palette naming convention:
//   --md-ref-palette-primary40, --md-ref-palette-neutral-variant90, etc.
//
// The variant flag matters: TonalSpot pins primary chroma at 36 while
// Vibrant/Expressive push it higher and rotate hues for secondary/tertiary,
// so the same seed produces different tonal palettes per variant.

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
} from "@material/material-color-utilities";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const args = process.argv.slice(2);
let seedHex, name, variantName = "tonal-spot", secondarySeedHex;
let harmonizeSecondary = false;
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--seed") seedHex = args[++i];
  else if (args[i] === "--name") name = args[++i];
  else if (args[i] === "--variant") variantName = args[++i];
  else if (args[i] === "--secondary-seed") secondarySeedHex = args[++i];
  else if (args[i] === "--harmonize-secondary") harmonizeSecondary = true;
}
if (!seedHex || !name) {
  console.error("Usage: node scripts/generate-m3-tonal-palettes.mjs --seed <hex> --name <slug> [--variant tonal-spot|vibrant|expressive|fidelity|content|monochrome|neutral|rainbow|fruit-salad] [--secondary-seed <hex>] [--harmonize-secondary]");
  process.exit(1);
}
if (harmonizeSecondary && !secondarySeedHex) {
  console.error("--harmonize-secondary requires --secondary-seed");
  process.exit(1);
}

// Mirror generate-m3-palette.mjs's --harmonize-secondary: nudge the
// secondary seed's hue toward the primary seed so the resulting tonal
// palette feels palette-compatible rather than imported.
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
const primaryHct = parseHct(seedHex);
const secondaryHct = secondarySeedHex ? parseHct(secondarySeedHex) : null;

// Build scheme matching the convention used by generate-m3-palette.mjs so the
// resulting tonal palettes line up with the role tokens that script emits.
function buildScheme(Scheme, primaryHct, secondaryHct) {
  const base = new Scheme(primaryHct, false, 0);
  if (!secondaryHct) return base;
  return new DynamicScheme({
    sourceColorArgb: base.sourceColorArgb,
    variant: base.variant,
    contrastLevel: 0,
    isDark: false,
    primaryPalette: base.primaryPalette,
    secondaryPalette: TonalPalette.fromHueAndChroma(secondaryHct.hue, secondaryHct.chroma),
    tertiaryPalette: base.tertiaryPalette,
    neutralPalette: base.neutralPalette,
    neutralVariantPalette: base.neutralVariantPalette,
  });
}

const scheme = buildScheme(Scheme, primaryHct, secondaryHct);

// M3 reference tones, including the dense low-end set (0/5/10/15/20/25) that
// matters for emphasis layers in dark mode and the 95/99/100 high-end set
// used for surface tints.
const tones = [0, 5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80, 90, 95, 99, 100];

const palettes = {
  "primary":          scheme.primaryPalette,
  "secondary":        scheme.secondaryPalette,
  "tertiary":         scheme.tertiaryPalette,
  "neutral":          scheme.neutralPalette,
  "neutral-variant":  scheme.neutralVariantPalette,
};

const argbToRgb = (argb) => {
  const r = (argb >> 16) & 0xff, g = (argb >> 8) & 0xff, b = argb & 0xff;
  return `rgb(${r} ${g} ${b})`;
};
const argbToHex = (argb) => {
  const r = (argb >> 16) & 0xff, g = (argb >> 8) & 0xff, b = argb & 0xff;
  return "#" + [r, g, b].map((x) => x.toString(16).padStart(2, "0")).join("");
};

function emitCss() {
  const lines = [
    `:root[data-palette="${name}"] {`,
    `  /* Material 3 reference tonal palettes generated from ${seedHex} (${variantName}). */`,
  ];
  for (const [paletteName, palette] of Object.entries(palettes)) {
    lines.push(`  /* ${paletteName} */`);
    for (const tone of tones) {
      lines.push(`  --md-ref-palette-${paletteName}${tone}: ${argbToRgb(palette.tone(tone))};`);
    }
  }
  lines.push("}", "");
  return lines.join("\n");
}

function emitJson() {
  const obj = {};
  for (const [paletteName, palette] of Object.entries(palettes)) {
    obj[paletteName] = {};
    for (const tone of tones) {
      obj[paletteName][tone] = argbToHex(palette.tone(tone));
    }
  }
  return JSON.stringify(obj, null, 2) + "\n";
}

const outDir = path.join(repoRoot, "themes/esio-theme/assets/css/m3", name);
await mkdir(outDir, { recursive: true });
await writeFile(path.join(outDir, "tones.css"), emitCss());
await writeFile(path.join(outDir, "tones.json"), emitJson());

console.log(`tonal palettes for '${name}' (${variantName}) written from seed ${seedHex}`);
console.log(`  out: themes/esio-theme/assets/css/m3/${name}/tones.{css,json}`);
