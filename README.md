# ESIO marketing site (Hugo)

Static marketing site for ESIO, built with Hugo + Tailwind 4.

The previous Astro site lives in `old/` for reference. The Hugo source of truth is the project root from `hugo.toml` outward.

## Local development

```sh
npm install                # one-time, installs the Tailwind 4 CLI binary
npm run dev                # `hugo server` on http://localhost:1313
npm run build              # `hugo --minify` -> public/
```

Hugo is pinned to ≥ 0.128 (for `css.TailwindCSS`). The repo was developed against Hugo 0.161 extended.

## Project layout

```
.
├── hugo.toml              # site config + design tokens (colors, typography, radii)
├── content/               # all page copy
│   ├── _index.md          # homepage front-matter
│   ├── articles/          # long-form content
│   ├── posts/             # blog updates
│   └── legal/             # privacy / terms / cookies / GDPR
├── data/sections/*.yml    # homepage section copy (hero, pricing tiers, ...)
├── static/                # files served as-is (favicons, SVG illustrations)
├── themes/esio-theme/     # ALL templates and styles live here
│   ├── layouts/           # baseof, content-type layouts, section partials
│   └── assets/css/        # styles.css (with Tailwind 4 @theme block) + esio.css
└── old/                   # previous Astro site, kept for reference
```

## Editing rules

This site is intentionally strict about separation of concerns.

| File type           | Owns                                         | Never contains                           |
|---------------------|----------------------------------------------|------------------------------------------|
| `hugo.toml`         | colors, fonts, radii, site metadata          | content copy                             |
| `content/*.md`      | long-form text                               | layout, hex colors                       |
| `data/sections/*.yml` | structured copy for homepage sections       | layout, hex colors                       |
| `themes/.../*.html` | structure + Hugo template logic              | content copy, hex colors, inline styles  |
| `themes/.../*.css`  | typography, layout, animations               | content copy                             |

To re-skin the site, edit `[params.colors]` in `hugo.toml`. To reword a section, edit the relevant YAML in `data/sections/`.

## Adding content

- **Article**: `hugo new content articles/my-piece.md`
- **Post**: `hugo new content posts/whats-new.md`
- **Legal doc**: `hugo new content legal/some-policy.md`

## Editing via Pages CMS

The repo ships with a `.pages.yml` config so the site can be edited at [app.pagescms.org](https://app.pagescms.org/). Sign in with GitHub, point Pages CMS at this repo, and editors get:

- **Homepage metadata** — title and description.
- **Section forms** — one form per data file (Navigation, Hero, Video, Pain, Features, Pricing, Subscribe, Footer). Each maps 1:1 to `data/sections/<name>.yml`.
- **Articles / Blog posts / Legal documents** — three markdown collections with rich-text body editors. Filenames are auto-slugged from the title.
- **Asset uploads** — anything dropped into the media picker lands in `static/assets/` and is referenced as `/assets/...` in the rendered site.

Saves commit to GitHub on the editor's behalf. CI (or your deploy hook) rebuilds the site.

## Deploying

`npm run build` produces a static `public/` ready for any CDN (Cloudflare Pages, Netlify, GitHub Pages, S3+CloudFront).
