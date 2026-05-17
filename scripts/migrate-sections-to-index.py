#!/usr/bin/env python3
"""
One-off migration: data/<lang>/sections/*.yml  →  data/<lang>/index/<section>/...

Splits structured-object lists into sub-folders with one file per item; keeps
string-only lists and small inline data in meta.yml (or intro.yml for the
features/team sections, which use an "intro" wrapper conceptually).

Safe to re-run: it wipes data/<lang>/index/ before writing.
After running, the old data/<lang>/sections/ trees can be deleted by hand
(left in place by this script so a partial migration is easy to roll back).
"""
from __future__ import annotations

import shutil
from pathlib import Path

try:
    import yaml
except ImportError as exc:  # noqa: BLE001
    raise SystemExit("PyYAML required: pip install pyyaml") from exc


def _str_representer(dumper, data):
    # Use block scalar (|) for strings containing newlines so editors see a
    # readable multi-line value instead of a quoted blob with blank-line folds.
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, _str_representer)


ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
LANGS = ("en", "da")

# section → list of (sub-folder name, source field on the original YAML)
# Anything NOT in this map stays inline in meta.yml.
SPLITS: dict[str, list[tuple[str, str]]] = {
    "nav":      [("links", "links"), ("actions", "actions")],
    "hero":     [],
    "video":    [],
    "pain":     [("cards", "cards"), ("badges", "badges")],
    "features": [("panels", "panels")],
    "pricing":  [("tiers", "tiers")],
    "subscribe": [],
    "newsletter": [],
    "team":     [("members", "members")],
    "footer":   [("columns", "columns")],
}

# Sections that use "intro.yml" instead of "meta.yml" because their
# conceptual root is the intro panel, not a generic header block.
INTRO_SECTIONS = {"features", "team"}


def slugify(value: str | None, fallback: int) -> str:
    if not value:
        return f"item-{fallback:02d}"
    cleaned = (
        value.lower()
        .replace("'", "")
        .replace("&", "and")
        .replace("/", "-")
        .replace(" ", "-")
        .replace("·", "-")
        .replace("—", "-")
        .replace(".", "")
        .replace(":", "")
    )
    while "--" in cleaned:
        cleaned = cleaned.replace("--", "-")
    return cleaned.strip("-")[:40] or f"item-{fallback:02d}"


def pick_slug(item: dict, index: int) -> str:
    for key in ("id", "slug", "name", "label", "title", "heading"):
        v = item.get(key)
        if isinstance(v, str) and v.strip():
            return slugify(v, index)
    return f"item-{index:02d}"


def dump_yaml(path: Path, data) -> None:
    path.write_text(
        yaml.dump(data, sort_keys=False, allow_unicode=True, width=4096),
        encoding="utf-8",
    )


def migrate_lang(lang: str) -> None:
    src = DATA / lang / "sections"
    if not src.is_dir():
        print(f"  skip {lang}: no sections/ folder")
        return

    dst = DATA / lang / "index"
    dst.mkdir(parents=True, exist_ok=True)

    for yml in sorted(src.glob("*.yml")):
        section = yml.stem
        payload = yaml.safe_load(yml.read_text(encoding="utf-8")) or {}
        section_dir = dst / section
        # Wipe only the sections we own — anything else under index/
        # (sections added manually after the migration, e.g. `how/`) survives.
        if section_dir.exists():
            shutil.rmtree(section_dir)
        section_dir.mkdir()

        for sub_name, field in SPLITS.get(section, []):
            items = payload.pop(field, None) or []
            if not items:
                continue
            sub_dir = section_dir / sub_name
            sub_dir.mkdir()
            for i, item in enumerate(items, 1):
                slug = pick_slug(item, i)
                dump_yaml(sub_dir / f"{i:02d}-{slug}.yml", item)

        # Remaining keys go to meta.yml (or intro.yml for features/team).
        meta_name = "intro.yml" if section in INTRO_SECTIONS else "meta.yml"
        if section == "features":
            # Unwrap the "intro" key so partials read $data.intro.headline,
            # not $data.intro.intro.headline.
            intro_payload = payload.pop("intro", {}) or {}
            dump_yaml(section_dir / meta_name, intro_payload)
            if payload:
                dump_yaml(section_dir / "_other.yml", payload)
        elif section == "team":
            # Flatten the team intro and nest the closing CTA inside it so
            # everything that belongs to the header block lives in intro.yml.
            intro_payload = payload.pop("intro", {}) or {}
            cta_payload = payload.pop("cta", None)
            if cta_payload is not None:
                intro_payload["cta"] = cta_payload
            dump_yaml(section_dir / meta_name, intro_payload)
            if payload:
                dump_yaml(section_dir / "_other.yml", payload)
        else:
            dump_yaml(section_dir / meta_name, payload)


def main() -> None:
    for lang in LANGS:
        print(f"migrating {lang}…")
        migrate_lang(lang)
    print("done.")


if __name__ == "__main__":
    main()
