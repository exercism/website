export const normalizeLocale = (locale: string): string =>
  locale.toLowerCase().replace('_', '-')

export const getCurrentLocaleFromPath = (): string | null => {
  const pathSegment = window.location.pathname.split('/')[1]
  return pathSegment ? normalizeLocale(pathSegment) : null
}

export const buildNewUrl = (locale: string): string => {
  const parts = window.location.pathname.split('/')
  parts[1] = locale
  const newPath = parts.join('/') || `/${locale}`
  return `${newPath}${window.location.search}${window.location.hash}`
}

export const findBestMatch = (
  targetLocale: string,
  supportedLocales: string[]
): string | null => {
  const normalized = normalizeLocale(targetLocale)
  const normalizedSupported = supportedLocales.map(normalizeLocale)

  // exact match
  if (normalizedSupported.includes(normalized)) {
    return normalized
  }

  // language code match (e.g., 'en' matches 'en-us')
  const languageCode = normalized.split('-')[0]
  const languageVariant = normalizedSupported.find(
    (locale) => locale.split('-')[0] === languageCode
  )

  return languageVariant || null
}

export const getUserPreferredLocale = (
  supportedLocales: string[],
  localStorageKey: string
): string | null => {
  // check localStorage
  const stored = localStorage.getItem(localStorageKey)
  if (stored) {
    return findBestMatch(stored, supportedLocales)
  }

  // check browser languages
  const browserLocales = [
    ...(navigator.languages || []),
    navigator.language,
  ].filter(Boolean)

  for (const locale of browserLocales) {
    const match = findBestMatch(locale, supportedLocales)
    if (match) return match
  }

  return null
}
