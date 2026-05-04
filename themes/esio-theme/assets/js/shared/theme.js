// Theme toggle. The <html data-theme="..."> attribute is set in a tiny
// inline script in baseof.html before paint to avoid a flash; this module
// only handles the user-initiated toggle.
const KEY = 'esio-theme';

function apply(theme) {
  document.documentElement.dataset.theme = theme;
  try { localStorage.setItem(KEY, theme); } catch (_) {}
  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.checked = theme === 'light';
  });
}

export function initTheme() {
  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.checked = document.documentElement.dataset.theme === 'light';
    el.addEventListener('change', (e) => {
      apply(e.target.checked ? 'light' : 'dark');
    });
  });
}
