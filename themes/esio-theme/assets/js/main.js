import './shared/toggler'
import { initTheme } from './shared/theme'
import { initEngagement } from './shared/umami-engagement'
import { initNewsletterForm } from './shared/newsletter-form'
import { initScrollReveal } from './shared/motion'

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initEngagement();
  initNewsletterForm();
  initScrollReveal();
});
