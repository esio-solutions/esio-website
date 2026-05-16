import './shared/toggler'
import { initTheme } from './shared/theme'
import { initEngagement } from './shared/umami-engagement'
import { initNewsletterForm } from './shared/newsletter-form'

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initEngagement();
  initNewsletterForm();
});
