// Rails renders the session's authenticity token into a meta tag
// (via csrf_meta_tags). Requests to non-API endpoints send it back in
// this header so that Rails' forgery protection accepts them.
export function csrfHeaders(): Record<string, string> {
  const token = document.querySelector<HTMLMetaElement>(
    'meta[name="csrf-token"]'
  )?.content

  return token ? { 'X-CSRF-Token': token } : {}
}
