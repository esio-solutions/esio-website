// AJAX newsletter signup. Intercepts the form's submit, POSTs JSON to
// Listmonk's public subscription API (proxied through altcha-verify on
// captcha.esio.dk), and shows inline status feedback instead of navigating
// away. Falls back to plain form submission if the form's data-endpoint
// attribute is missing.
//
// Required form data-* attributes (set in newsletter-form.html):
//   data-endpoint            JSON API URL (Listmonk's /api/public/subscription)
//   data-list-uuid           List UUID to subscribe to
//   data-msg-submitting      Status text shown during request
//   data-msg-success         Status text on 2xx
//   data-msg-error           Status text on non-2xx response
//   data-msg-error-network   Status text on fetch failure
//   data-msg-error-captcha   Status text when altcha proof hasn't been set

function setStatus(el, text, state) {
  if (!el) return;
  el.textContent = text;
  el.className = `newsletter-status is-${state}`;
}

export function initNewsletterForm() {
  const form = document.querySelector('.newsletter-form');
  if (!form || !form.dataset.endpoint) return;

  const status = form.querySelector('.newsletter-status');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const data = new FormData(form);
    const altcha = data.get('altcha');
    if (!altcha) {
      setStatus(status, form.dataset.msgErrorCaptcha, 'error');
      return;
    }

    setStatus(status, form.dataset.msgSubmitting, 'pending');

    const body = JSON.stringify({
      email: data.get('email'),
      name: data.get('name') || '',
      list_uuids: [form.dataset.listUuid],
      altcha,
    });

    try {
      const resp = await fetch(form.dataset.endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body,
      });
      if (resp.ok) {
        setStatus(status, form.dataset.msgSuccess, 'success');
        form.reset();
      } else {
        setStatus(status, form.dataset.msgError, 'error');
      }
    } catch (err) {
      setStatus(status, form.dataset.msgErrorNetwork, 'error');
    }
  });
}
