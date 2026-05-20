#!/usr/bin/env node
// Generate a Material 3 palette folder for the esio-theme.
//
// Usage:
//   node scripts/generate-m3-palette.mjs --seed <hex> --name <slug> [--variant <name>]
//
// Writes 6 CSS files to themes/esio-theme/assets/css/m3/<slug>/ matching the
// project's selector convention. Uses @material/material-color-utilities with
// the default '2021' spec, so output matches the web Material Theme Builder.
//
// Scheme variants accepted (default TonalSpot):
//   tonal-spot | vibrant | expressive | fidelity | content
//   monochrome | neutral | rainbow | fruit-salad

import {
  argbFromHex,
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
  MaterialDynamicColors,
} from "@material/material-color-utilities";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const args = process.argv.slice(2);
let seedHex, name, variantName = "tonal-spot";
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--seed") seedHex = args[++i];
  else if (args[i] === "--name") name = args[++i];
  else if (args[i] === "--variant") variantName = args[++i];
}
if (!seedHex || !name) {
  console.error("Usage: node scripts/generate-m3-palette.mjs --seed <hex> --name <slug> [--variant tonal-spot|vibrant|expressive|fidelity|content|monochrome|neutral|rainbow|fruit-salad]");
  process.exit(1);
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

const hct = Hct.fromInt(argbFromHex(seedHex.startsWith("#") ? seedHex : `#${seedHex}`));

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

function emit(selector, scheme) {
  const lines = [`${selector} {`];
  for (const token of tokens) {
    const dc = MaterialDynamicColors[token];
    lines.push(`  --md-sys-color-${kebab(token)}: ${argbToRgb(dc.getArgb(scheme))};`);
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
    const dc = MaterialDynamicColors[token];
    obj[kebab(token)] = argbToHex(dc.getArgb(scheme));
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
  const scheme = new Scheme(hct, f.isDark, f.contrast);
  await writeFile(path.join(outDir, f.file), emit(f.selector, scheme));
}

// Also emit JSON sidecars for light.css and dark.css so the Typst marketing
// renderer can consume the same tokens without a CSS parser.
const jsonFiles = [
  { file: "light.json", isDark: false, contrast: 0 },
  { file: "dark.json",  isDark: true,  contrast: 0 },
];
for (const f of jsonFiles) {
  const scheme = new Scheme(hct, f.isDark, f.contrast);
  await writeFile(path.join(outDir, f.file), emitJson(scheme));
}

// Report the swatch hex (primary at the light scheme — what the picker chip
// should show). Use this for [[params.m3.options]].swatch in hugo.toml.
const lightScheme = new Scheme(hct, false, 0);
const swatch = argbToHex(MaterialDynamicColors.primary.getArgb(lightScheme));
console.log(`palette '${name}' (${variantName}) generated from seed ${seedHex}`);
console.log(`  out: themes/esio-theme/assets/css/m3/${name}/`);
console.log(`  picker swatch (use for hugo.toml): ${swatch}`);
