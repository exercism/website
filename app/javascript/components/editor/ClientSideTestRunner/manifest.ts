import { ManifestEntry } from './types'

/**
 * Which languages can run their tests in the browser, and what to load.
 *
 * Served same-origin from `/test-runners/`, which Cloudflare routes to the
 * assets CloudFront distribution. Same-origin is not incidental: `new Worker()`
 * only accepts a same-origin script URL, and the kernel runs in a worker.
 *
 * `<language>/latest.json` is cached for a minute; everything it points at is
 * immutable and cached for a year. So this fetch is cheap, and it is what lets
 * a language be published, updated or withdrawn without deploying the website.
 */
const BASE = '/test-runners/'

const cache = new Map<string, Promise<ManifestEntry | null>>()

/**
 * The manifest entry for a language, or null if it has none.
 *
 * Null is the normal answer, not an error: most tracks have no client-side
 * runner and must run their tests on the server. Every failure resolves the
 * same way - a 404, a network blip, a malformed body - because there is
 * nothing a student can do about any of them, and the server-side run is a
 * complete fallback.
 *
 * Memoised for the life of the page so repeated runs don't revalidate.
 */
export function lookup(language: string): Promise<ManifestEntry | null> {
  const cached = cache.get(language)
  if (cached) return cached

  const request = fetch(`${BASE}${language}/latest.json`)
    .then((response) => (response.ok ? response.json() : null))
    .then((entry) => (isValid(entry) ? entry : null))
    .catch(() => null)

  cache.set(language, request)
  return request
}

/**
 * The manifest is deployed independently of this code, so treat it as
 * untrusted input: a half-written or rolled-back entry should degrade to a
 * server-side run rather than throwing somewhere deep in the boot.
 */
function isValid(entry: unknown): entry is ManifestEntry {
  if (!entry || typeof entry !== 'object') return false
  const candidate = entry as Partial<ManifestEntry>

  return (
    candidate.type === 'kernel' &&
    typeof candidate.timeout === 'number' &&
    typeof candidate.kernel === 'string' &&
    typeof candidate.boot === 'string' &&
    typeof candidate.sysroot === 'string' &&
    typeof candidate.testRunner === 'string'
  )
}
