// Theme switcher. The <html data-theme="..."> attribute is set in a tiny
// inline script in baseof.html before paint to avoid a flash; this module
// only handles user-initiated switching.
//
// Each palette swatch in theme-toggle.html carries [data-theme-set="<slug>"];
// clicking one flips the attribute and persists the choice. The legacy
// [data-theme-toggle] binding (dark↔light cycle) is kept for any callsite
// that still uses it.
const KEY = 'esio-theme';

function apply(theme) {
  const swap = () => {
    document.documentElement.dataset.theme = theme;
    try { localStorage.setItem(KEY, theme); } catch (_) {}
    document.querySelectorAll('[data-theme-set]').forEach((el) => {
      el.classList.toggle('is-active', el.dataset.themeSet === theme);
    });
  };

  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reduceMotion) {
    swap();
    return;
  }

  // Modern path: View Transitions API. Browser snapshots the page,
  // applies the swap, snapshots again, then crossfades the two bitmaps
  // on the GPU. Customised via ::view-transition-old/new(root) in CSS.
  if (typeof document.startViewTransition === 'function') {
    document.startViewTransition(swap);
    return;
  }

  // Fallback for older Firefox / Safari: a temporary class on <html>
  // scopes a global color transition to the moment of the swap. Less
  // smooth than the API but better than a hard cut. Window matches the
  // CSS transition duration in esio.css (760ms) plus a small buffer.
  document.documentElement.classList.add('theme-transitioning');
  swap();
  window.setTimeout(() => {
    document.documentElement.classList.remove('theme-transitioning');
  }, 820);
}

export function initTheme() {
  // Mark whichever swatch matches the current theme on first paint so the
  // active ring shows immediately.
  apply(document.documentElement.dataset.theme);

  document.querySelectorAll('[data-theme-set]').forEach((el) => {
    el.addEventListener('click', () => apply(el.dataset.themeSet));
  });

  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.addEventListener('click', () => {
      const current = document.documentElement.dataset.theme;
      apply(current === 'light' ? 'dark' : 'light');
    });
  });
}
