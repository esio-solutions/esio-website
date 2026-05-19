import { chromium } from 'playwright';
import http from 'node:http';
import { readFile, readdir, mkdir, stat } from 'node:fs/promises';
import path from 'node:path';

const PUBLIC_DIR = process.env.PUBLIC_DIR ?? '/work/public';
const OUTPUT_DIR = process.env.OUTPUT_DIR ?? '/work/output';
const LANGS  = (process.env.LANGS  ?? 'en,da').split(',');
const THEMES = (process.env.THEMES ?? 'dark,light,app-preview').split(',');

const FORMATS = [
  { name: 'instagram',  dir: 'marketing/instagram',  viewport: { width: 1080, height: 1350 }, slidePattern: /^\d{2}-/ },
  { name: 'facebook',   dir: 'marketing/facebook',   viewport: { width: 1200, height: 630  }, slidePattern: /^\d{2}-/ },
  { name: 'linkedin',   dir: 'marketing/linkedin',   viewport: { width: 1200, height: 1200 }, slidePattern: /^\d{2}-/ },
  { name: 'google-ads', dir: 'marketing/google-ads',                                           slidePattern: /^\d+x\d+$/, viewportFromName: true },
];

// Matches hugo.toml: defaultContentLanguageInSubdir = false → English at root.
const langPrefix = (lang) => (lang === 'en' ? '' : `/${lang}`);

const DEVICE_SCALE_FACTOR = 2;
const JPEG_QUALITY = 92;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css':  'text/css; charset=utf-8',
  '.js':   'text/javascript; charset=utf-8',
  '.svg':  'image/svg+xml',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.woff': 'font/woff',
  '.woff2':'font/woff2',
  '.ttf':  'font/ttf',
  '.json': 'application/json',
  '.xml':  'application/xml',
};

const server = http.createServer(async (req, res) => {
  let urlPath = decodeURIComponent(req.url.split('?')[0]);
  if (urlPath.endsWith('/')) urlPath += 'index.html';
  const filePath = path.join(PUBLIC_DIR, urlPath);
  try {
    const data = await readFile(filePath);
    res.writeHead(200, { 'Content-Type': MIME[path.extname(filePath)] ?? 'application/octet-stream' });
    res.end(data);
  } catch {
    res.writeHead(404);
    res.end(`not found: ${req.url}`);
  }
});

async function discoverSlides(fmt) {
  const slidesRoot = path.join(PUBLIC_DIR, fmt.dir);
  const entries = await readdir(slidesRoot, { withFileTypes: true });
  return entries
    .filter(e => e.isDirectory() && fmt.slidePattern.test(e.name))
    .map(e => e.name)
    .sort();
}

// For formats like google-ads where the slide name encodes its own viewport
// (e.g. "300x250" or "728x90"), derive the viewport directly from the name.
function viewportForSlide(fmt, slide) {
  if (fmt.viewportFromName) {
    const m = slide.match(/^(\d+)x(\d+)$/);
    if (m) return { width: parseInt(m[1], 10), height: parseInt(m[2], 10) };
  }
  return fmt.viewport;
}

async function main() {
  await mkdir(OUTPUT_DIR, { recursive: true });

  try { await stat(PUBLIC_DIR); } catch {
    throw new Error(`missing mount: ${PUBLIC_DIR} — did Hugo build first?`);
  }

  await new Promise(r => server.listen(0, '127.0.0.1', r));
  const port = server.address().port;
  const base = `http://127.0.0.1:${port}`;
  console.log(`[render] static server bound on ${base}`);

  const browser = await chromium.launch();

  let totalWritten = 0;
  for (const fmt of FORMATS) {
    const slides = await discoverSlides(fmt);
    if (slides.length === 0) {
      console.warn(`[render] no slide directories under ${fmt.dir} — skipping`);
      continue;
    }

    const planned = slides.length * LANGS.length * THEMES.length;
    const vpLabel = fmt.viewportFromName ? 'per-slide viewport' : `${fmt.viewport.width}×${fmt.viewport.height}`;
    console.log(`[render] ${fmt.name} (${vpLabel}) → ${planned} JPGs`);

    for (const lang of LANGS) {
      const prefix = langPrefix(lang);
      for (const theme of THEMES) {
        const outDir = path.join(OUTPUT_DIR, fmt.name, lang, theme);
        await mkdir(outDir, { recursive: true });
        for (const slide of slides) {
          const vp = viewportForSlide(fmt, slide);
          // Per-slide viewport requires a fresh context, since viewport is
          // a context-level setting. Cheap enough at our scale.
          const context = await browser.newContext({
            viewport: vp,
            deviceScaleFactor: DEVICE_SCALE_FACTOR,
          });
          const page = await context.newPage();
          const url = `${base}${prefix}/${fmt.dir}/${slide}/?theme=${theme}`;
          await page.goto(url, { waitUntil: 'networkidle' });
          await page.evaluate(() => document.fonts.ready);
          const out = path.join(outDir, `${slide}.jpg`);
          await page.screenshot({
            path: out,
            type: 'jpeg',
            quality: JPEG_QUALITY,
            clip: { x: 0, y: 0, ...vp },
          });
          console.log(`[render] wrote ${out}`);
          await context.close();
          totalWritten++;
        }
      }
    }
  }

  console.log(`[render] done. ${totalWritten} JPG(s) total.`);

  await browser.close();
  server.close();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
