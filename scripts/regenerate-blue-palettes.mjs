#!/usr/bin/env node
// Regenerate the 5 blue-* M3 palette folders, sourcing the secondary
// seed from [params.colors].yellow in hugo.toml. Keeps the brand color
// as a single source of truth: edit yellow in hugo.toml, re-run this,
// and every variant's secondary family follows.
//
// No --pin, no --harmonize — the M3 algorithm normalizes the seed
// naturally so secondary-fixed-dim ends up at tone-80 of a palette
// derived from the brand color (not exactly the brand hex, but in
// the same hue family).
//
// Usage:
//   node scripts/regenerate-blue-palettes.mjs [--seed <primary-hex>]
//
// Default primary seed is #3482E7 (the brand blue the blue-* palettes
// were originally generated from). Pass --seed to override.

import { readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const args = process.argv.slice(2);
let primarySeed = "#3482E7";
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--seed") primarySeed = args[++i];
}

const hugoToml = readFileSync(path.join(repoRoot, "hugo.toml"), "utf8");
const match = hugoToml.match(/^\s*yellow\s*=\s*"(#[0-9a-fA-F]{6})"/m);
if (!match) {
  console.error("Could not find [params.colors].yellow in hugo.toml");
  process.exit(1);
}
const secondarySeed = match[1];

const VARIANTS = ["tonal-spot", "vibrant", "expressive", "neutral", "monochrome"];

console.log(`primary  ${primarySeed}  (from --seed)`);
console.log(`secondary ${secondarySeed}  (from [params.colors].yellow)\n`);

for (const variant of VARIANTS) {
  const name = `blue-${variant}`;
  for (const script of [
    "scripts/generate-m3-palette.mjs",
    "scripts/generate-m3-tonal-palettes.mjs",
  ]) {
    const result = spawnSync("node", [
      script,
      "--seed", primarySeed,
      "--name", name,
      "--variant", variant,
      "--secondary-seed", secondarySeed,
    ], { stdio: "inherit" });
    if (result.status !== 0) process.exit(result.status);
  }
}
