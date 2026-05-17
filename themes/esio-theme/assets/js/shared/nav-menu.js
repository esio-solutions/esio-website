// Burger menu auto-close behavior.
//
// The burger button toggles `.is-menu-open` on `body > nav` via the
// generic toggler.js. This module adds three close triggers on top:
//
//   • click on a nav link or the in-menu CTA → close (user navigated away)
//   • click anywhere outside the nav element  → close (user dismissed it)
//   • Escape key                              → close (keyboard dismiss)
//
// Theme swatches and language flags inside the menu DO NOT close it —
// the user may want to toggle multiple settings in one session.

const NAV_SELECTOR = 'body > nav';
const OPEN_CLASS = 'is-menu-open';

function closeMenu() {
  const nav = document.querySelector(NAV_SELECTOR);
  if (nav) nav.classList.remove(OPEN_CLASS);
}

export function initNavMenu() {
  const nav = document.querySelector(NAV_SELECTOR);
  if (!nav) return;

  // Close when a navigation link or the CTA inside the menu is activated.
  const closeOnClick = nav.querySelectorAll('.nav-links a, .nav-menu-cta a, .nav-menu-cta button');
  closeOnClick.forEach((el) => {
    el.addEventListener('click', closeMenu);
  });

  // Close on outside click. The handler is no-op when the menu is closed,
  // and skips when the click is inside the nav (so theme/lang toggles and
  // the burger itself don't accidentally trigger a close-then-reopen).
  document.addEventListener('click', (e) => {
    if (!nav.classList.contains(OPEN_CLASS)) return;
    if (nav.contains(e.target)) return;
    closeMenu();
  });

  // Escape key dismisses the menu (accessibility — keyboard users expect
  // this for any popover/menu).
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && nav.classList.contains(OPEN_CLASS)) {
      closeMenu();
    }
  });
}
