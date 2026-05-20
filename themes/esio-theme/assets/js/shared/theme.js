// Theme + palette switcher. Both attributes (data-theme, data-palette) are
// set in a tiny inline script in baseof.html before paint to avoid a flash;
// this module only handles user-initiated swaps.
//
// Theme swatches in settings.html carry [data-theme-set="<slug>"]; palette
// swatches carry [data-palette-set="<slug>"]. Clicking flips the
// corresponding attribute on <html> and persists the choice to localStorage.
// The legacy [data-theme-toggle] binding (dark↔light cycle) is kept.

const THEME_KEY   = 'esio-theme';
const PALETTE_KEY = 'esio-palette';

// Wrap an attribute write in a View Transition / class-based fade so it
// crossfades rather than hard-cuts. Same machinery for both theme and palette
// — the only thing that changes is what swap() does.
function transition(swap) {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reduceMotion) { swap(); return; }
  if (typeof document.startViewTransition === 'function') {
    document.startViewTransition(swap);
    return;
  }
  document.documentElement.classList.add('theme-transitioning');
  swap();
  window.setTimeout(() => {
    document.documentElement.classList.remove('theme-transitioning');
  }, 820);
}

function applyTheme(theme) {
  transition(() => {
    document.documentElement.dataset.theme = theme;
    try { localStorage.setItem(THEME_KEY, theme); } catch (_) {}
    document.querySelectorAll('[data-theme-set]').forEach((el) => {
      el.classList.toggle('is-active', el.dataset.themeSet === theme);
    });
  });
}

function applyPalette(palette) {
  transition(() => {
    document.documentElement.dataset.palette = palette;
    try { localStorage.setItem(PALETTE_KEY, palette); } catch (_) {}
    document.querySelectorAll('[data-palette-set]').forEach((el) => {
      el.classList.toggle('is-active', el.dataset.paletteSet === palette);
    });
  });
}

export function initTheme() {
  // Mark whichever swatches match the current state on first paint so the
  // active rings show immediately.
  applyTheme(document.documentElement.dataset.theme);
  applyPalette(document.documentElement.dataset.palette);

  document.querySelectorAll('[data-theme-set]').forEach((el) => {
    el.addEventListener('click', () => applyTheme(el.dataset.themeSet));
  });

  document.querySelectorAll('[data-palette-set]').forEach((el) => {
    el.addEventListener('click', () => applyPalette(el.dataset.paletteSet));
  });

  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.addEventListener('click', () => {
      const current = document.documentElement.dataset.theme;
      applyTheme(current === 'light' ? 'dark' : 'light');
    });
  });
}
