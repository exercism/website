export const normalizeLocale = (locale: string): string =>
  locale.trim().toLowerCase().replace(/_/g, '-')

export const getLanguageCode = (locale: string): string =>
  normalizeLocale(locale).split('-')[0]

const firstPathSegment = (path: string): string =>
  (path.startsWith('/') ? path.slice(1) : path).split('/')[0] || ''

/**
 * Detects whether the URL path already contains a locale as its first segment.
 * Returns the matched (normalized) locale if it’s supported, otherwise null.
 */
export const detectLocaleFromPath = (
  supportedLocales: string[]
): { locale: string | null; hasLocaleInPath: boolean } => {
  const segRaw = firstPathSegment(window.location.pathname)
  const seg = normalizeLocale(segRaw)
  const supportedNorm = supportedLocales.map(normalizeLocale)

  if (!seg) return { locale: null, hasLocaleInPath: false }

  // exact match
  if (supportedNorm.includes(seg)) return { locale: seg, hasLocaleInPath: true }

  // short language code that we support e.g. "/en/..."
  if (supportedNorm.includes(getLanguageCode(seg))) {
    return { locale: getLanguageCode(seg), hasLocaleInPath: true }
  }

  // if the segment is a language code that has a full supported variant (e.g., "/pt/" → "pt-br" supported)
  const variant = supportedNorm.find((s) => getLanguageCode(s) === seg)
  if (variant) return { locale: variant, hasLocaleInPath: true }

  return { locale: null, hasLocaleInPath: false }
}

export const buildNewUrl = (
  locale: string,
  supportedLocales: string[]
): string => {
  const target = normalizeLocale(locale)
  const supportedNorm = supportedLocales.map(normalizeLocale)

  const path = window.location.pathname
  const parts = (path.startsWith('/') ? path.slice(1) : path).split('/')

  const { hasLocaleInPath } = detectLocaleFromPath(supportedLocales)

  if (hasLocaleInPath) {
    parts[0] = supportedNorm.includes(target)
      ? target
      : supportedNorm.find(
          (s) => getLanguageCode(s) === getLanguageCode(target)
        ) || target
  } else {
    parts.unshift(target)
  }

  const newPath = `/${parts.filter(Boolean).join('/')}`
  return `${newPath}${window.location.search}${window.location.hash}`
}

export const findBestMatch = (
  targetLocale: string,
  supportedLocales: string[]
): string | null => {
  const normalized = normalizeLocale(targetLocale)
  const languageCode = getLanguageCode(normalized)
  const supportedNorm = supportedLocales.map(normalizeLocale)

  if (supportedNorm.includes(normalized)) return normalized

  const variant = supportedNorm.find(
    (loc) => getLanguageCode(loc) === languageCode
  )
  if (variant) return variant

  if (supportedNorm.includes(languageCode)) return languageCode

  return null
}

export const getUserPreferredLocale = (
  supportedLocales: string[],
  localStorageKey: string
): string | null => {
  const stored = localStorage.getItem(localStorageKey)
  if (stored) {
    const match = findBestMatch(stored, supportedLocales)
    if (match) return match
  }

  const browserLocales = [
    ...(navigator.languages || []),
    navigator.language,
  ].filter(Boolean) as string[]

  for (const loc of browserLocales) {
    const match = findBestMatch(loc, supportedLocales)
    if (match) return match
  }

  return null
}

/**
 * Scenarios:
 * 1) URL has locale + browser has different -> [browser, current, fallback]
 * 2) URL has locale + browser same lang -> [current, fallback] (we won’t open in this case)
 * 3) URL has NO locale + browser has -> [browser, fallback]
 */
export const buildLocaleChoices = (params: {
  supportedLocales: string[]
  currentLocale: string | null
  preferredLocale: string | null
  fallbackLocale?: string
}): string[] => {
  const {
    supportedLocales,
    currentLocale,
    preferredLocale,
    fallbackLocale = 'en',
  } = params
  const supportedNorm = supportedLocales.map(normalizeLocale)
  const pushIfValid = (arr: string[], loc: string | null | undefined) => {
    if (!loc) return
    const n = normalizeLocale(loc)
    if (!supportedNorm.includes(n)) return
    if (!arr.includes(n)) arr.push(n)
  }

  const ordered: string[] = []

  pushIfValid(ordered, preferredLocale)

  pushIfValid(ordered, currentLocale)

  pushIfValid(ordered, findBestMatch(fallbackLocale, supportedLocales))

  return ordered
}
