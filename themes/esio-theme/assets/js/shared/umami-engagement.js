// Fires Umami custom events for engagement signals beyond the default page-view:
//   - section-view-<id>  when a <section id> reaches 50% viewport visibility
//   - scroll-25 / 50 / 75 / 100  at scroll-depth milestones (once per page-view)
//   - engaged-30s / 60s / 120s  cumulative time while the tab is foregrounded
//
// All emits are no-ops if window.umami isn't yet loaded; Umami's tracker script
// is `defer`-loaded so it may not be available at DOMContentLoaded — each event
// independently checks at fire time rather than caching a reference.

const track = (name) => {
  if (window.umami && typeof window.umami.track === 'function') {
    window.umami.track(name);
  }
};

export function initEngagement() {
  // 1. Section visibility — fire once per section per page-view.
  const seenSections = new Set();
  document.querySelectorAll('section[id]').forEach((section) => {
    new IntersectionObserver(
      ([entry]) => {
        if (entry.intersectionRatio >= 0.5 && !seenSections.has(section.id)) {
          seenSections.add(section.id);
          track(`section-view-${section.id}`);
        }
      },
      { threshold: 0.5 }
    ).observe(section);
  });

  // 2. Scroll depth — fire once per milestone per page-view.
  const scrollMilestones = [25, 50, 75, 100];
  const firedScroll = new Set();
  let scrollTicking = false;
  const onScroll = () => {
    if (scrollTicking) return;
    scrollTicking = true;
    requestAnimationFrame(() => {
      const scrolled = window.scrollY + window.innerHeight;
      const total = document.documentElement.scrollHeight;
      const pct = total > 0 ? (scrolled / total) * 100 : 0;
      scrollMilestones.forEach((m) => {
        if (pct >= m && !firedScroll.has(m)) {
          firedScroll.add(m);
          track(`scroll-${m}`);
        }
      });
      scrollTicking = false;
    });
  };
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  // 3. Engaged-time milestones — count only while the tab is foregrounded.
  const timeMilestones = [30, 60, 120];
  const firedTime = new Set();
  let engagedMs = 0;
  let lastTickAt = Date.now();
  const intervalId = setInterval(() => {
    const now = Date.now();
    if (document.visibilityState === 'visible') {
      engagedMs += now - lastTickAt;
    }
    lastTickAt = now;
    timeMilestones.forEach((m) => {
      if (engagedMs / 1000 >= m && !firedTime.has(m)) {
        firedTime.add(m);
        track(`engaged-${m}s`);
      }
    });
    if (firedTime.size === timeMilestones.length) {
      clearInterval(intervalId);
    }
  }, 1000);
}
