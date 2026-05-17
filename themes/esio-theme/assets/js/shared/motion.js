// Motion enhancements — scroll-revealed sections. Gated behind
// prefers-reduced-motion so visitors who opt out get a fully static page.
// CSS does the visual work; this module just toggles `.is-visible` classes
// on observed elements as they enter the viewport.

const REVEAL_TARGETS = [
  '.tc',              // section title blocks (eyebrow + headline + subtitle)
  '.fp-subsection',   // feature panels rendered as subsections
  '.price-grid',      // pricing tier row — children stagger via CSS
  '.pain-cards',      // pain card row — same staggered pattern
  '.how-grid',        // how-it-works step row — same
  '.fp-bullets',      // intro panel bullet list — same
];

function prefersReducedMotion() {
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

export function initScrollReveal() {
  if (prefersReducedMotion()) return;
  if (typeof IntersectionObserver === 'undefined') return;

  const els = document.querySelectorAll(REVEAL_TARGETS.join(','));
  if (!els.length) return;

  // 15% visible + 50px bottom rootMargin means elements reveal slightly
  // before they're fully in view — smoother than waiting for the exact
  // edge-cross. Unobserve once visible; we don't want re-animation when
  // the visitor scrolls back up.
  const observer = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      }
    }
  }, {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px',
  });

  els.forEach((el) => observer.observe(el));
}

