import { metaLocale } from './page-locale'

export const LOCALE_HEADER = 'X-Exercism-Locale'

function sameOrigin(input: RequestInfo | URL): boolean {
  if (typeof window === 'undefined') return false

  const url =
    typeof input === 'string' || input instanceof URL ? input : input.url

  try {
    return new URL(url, window.location.href).origin === window.location.origin
  } catch {
    return false
  }
}

export function localeHeaders(
  input: RequestInfo | URL
): Record<string, string> {
  const locale = metaLocale()
  if (!locale || !sameOrigin(input)) return {}

  return { [LOCALE_HEADER]: locale }
}
