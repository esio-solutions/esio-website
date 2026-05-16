import './shared/toggler'
import { initTheme } from './shared/theme'
import { initEngagement } from './shared/umami-engagement'

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initEngagement();
});
