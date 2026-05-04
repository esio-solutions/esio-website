// Theme toggle. The <html data-theme="..."> attribute is set in a tiny
// inline script in baseof.html before paint to avoid a flash; this module
// only handles the user-initiated toggle.
//
// Bound to any element with [data-theme-toggle] — currently the icon button
// in the navbar (theme-toggle.html). Listens for `click` and flips the
// theme. Icon visibility is driven by CSS keyed off [data-theme] on <html>,
// so the JS doesn't manipulate icons directly.
const KEY = 'esio-theme';

function apply(theme) {
  document.documentElement.dataset.theme = theme;
  try { localStorage.setItem(KEY, theme); } catch (_) {}
}

export function initTheme() {
  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.addEventListener('click', () => {
      const current = document.documentElement.dataset.theme;
      apply(current === 'light' ? 'dark' : 'light');
    });
  });
}
