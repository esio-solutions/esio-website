# Pinned to match the playwright npm version in package.json so the
# bundled chromium revision and the npm API stay in lockstep.
FROM mcr.microsoft.com/playwright:v1.49.1-jammy

WORKDIR /opt/render

COPY package.json ./
RUN npm install --omit=dev && npm cache clean --force

COPY render.mjs ./

# Inputs / outputs (mounted by scripts/render-instagram-carousel.sh):
#   /work/public  → site's Hugo build (`hugo --minify` output)  [RO]
#   /work/output  → marketing/output                            [RW]
ENV PUBLIC_DIR=/work/public \
    OUTPUT_DIR=/work/output \
    LANGS=en,da \
    THEMES=dark,light,app-preview

ENTRYPOINT ["node", "/opt/render/render.mjs"]
