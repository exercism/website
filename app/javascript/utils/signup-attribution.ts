export const SIGNUP_ATTRIBUTION_COOKIE = '_exercism_attribution'

const NINETY_DAYS = 60 * 60 * 24 * 90
const MAX_LENGTH = 200
const UTM_PARAMS = [
  'utm_source',
  'utm_medium',
  'utm_campaign',
  'utm_content',
] as const

/**
 * Records where a visitor first arrived from, once per browser, so that the
 * server can attribute their signup.
 *
 * The server can't see this itself. Cloudflare serves most public pages to
 * logged-out visitors from its cache, so the first request often never
 * reaches us, and by signup time the referrer is our own sign-up page.
 *
 * The first touch wins. Someone who arrives from a search engine, leaves,
 * and signs up from a bookmark a week later is still attributed to the
 * search engine. The cookie is first-party and holds only these fields.
 *
 * Only the landing path is kept, never the full URL, because a first visit
 * can carry sensitive query parameters (such as a confirmation or reset
 * token). The UTM parameters are copied out on their own. The referrer is
 * cut down to its origin and path for the same reason.
 */
export function captureSignupAttribution(): void {
  if (typeof document === 'undefined') return

  try {
    if (hasAttributionCookie()) return

    const params = new URLSearchParams(window.location.search)
    const attribution: Record<string, string> = {}

    const referrer = externalReferrer()
    if (referrer) attribution.referrer = referrer
    attribution.landing_path = truncate(window.location.pathname)

    UTM_PARAMS.forEach((param) => {
      const value = params.get(param)
      if (value) attribution[param] = truncate(value)
    })

    document.cookie = `${SIGNUP_ATTRIBUTION_COOKIE}=${encodeURIComponent(
      JSON.stringify(attribution)
    )}; path=/; max-age=${NINETY_DAYS}; samesite=lax`
  } catch {
    // Attribution must never break the page.
  }
}

function hasAttributionCookie(): boolean {
  return document.cookie
    .split(';')
    .some((cookie) => cookie.trim().startsWith(`${SIGNUP_ATTRIBUTION_COOKIE}=`))
}

// A referrer from our own site says nothing about where someone came from.
function externalReferrer(): string | null {
  if (!document.referrer) return null

  const url = new URL(document.referrer)
  if (url.host === window.location.host) return null

  return truncate(`${url.origin}${url.pathname}`)
}

function truncate(value: string): string {
  return value.slice(0, MAX_LENGTH)
}
