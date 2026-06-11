// Theme (day/night) switcher. The data-theme attribute is set in a tiny
// inline script in baseof.html before paint to avoid a flash; this module
// only handles user-initiated swaps.
//
// Theme swatches in settings.html carry [data-theme-set="<slug>"]. Clicking
// flips data-theme on <html> and persists the choice to localStorage. The
// legacy [data-theme-toggle] binding (dark↔light cycle) is kept.

const THEME_KEY = 'esio-theme';

// Wrap an attribute write in a View Transition / class-based fade so it
// crossfades rather than hard-cuts.
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

export function initTheme() {
  // Mark whichever swatch matches the current state on first paint so the
  // active ring shows immediately.
  applyTheme(document.documentElement.dataset.theme);

  document.querySelectorAll('[data-theme-set]').forEach((el) => {
    el.addEventListener('click', () => applyTheme(el.dataset.themeSet));
  });

  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.addEventListener('click', () => {
      const current = document.documentElement.dataset.theme;
      applyTheme(current === 'light' ? 'dark' : 'light');
    });
  });
}
