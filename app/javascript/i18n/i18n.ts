import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import * as Sentry from '@sentry/react'

import en from './en'
import { DEFAULT_LOCALE, metaContent, pageLocale } from '@/utils/page-locale'

const CATALOG_META = 'exercism-i18n-catalog'

type Catalog = Record<string, Record<string, unknown>>

const loadedCatalogs = new Map<string, string>()
const reported = new Set<string>()
let queue: Promise<void> = Promise.resolve()

export { pageLocale }
const pageCatalogUrl = (): string | null => metaContent(CATALOG_META)

function report(locale: string, key: string): void {
  const id = `${locale}:${key}`
  if (reported.has(id)) return
  reported.add(id)

  Sentry.captureMessage(`Missing ${locale} translation: ${key}`, {
    level: 'warning',
    tags: { locale },
    fingerprint: ['i18n-missing', locale, key],
  })
}

if (!i18n.isInitialized) {
  i18n
    .use(initReactI18next)
    .init({
      fallbackLng: false,
      lng: pageLocale(),
      debug: process.env.NODE_ENV === 'development',
      interpolation: {
        escapeValue: false,
      },
      resources: {
        en,
      },
      saveMissing: true,
      missingKeyHandler: (_lngs, ns, key) =>
        report(i18n.language, `${ns}:${key}`),
    })
}

async function loadCatalog(locale: string, url: string): Promise<void> {
  try {
    const response = await fetch(url)
    if (!response.ok) throw new Error(`${response.status} for ${url}`)

    const catalog: Catalog = await response.json()

    // addResourceBundle merges, so keys removed upstream would live on without this
    Object.keys(i18n.getDataByLanguage(locale) || {}).forEach((ns) =>
      i18n.removeResourceBundle(locale, ns)
    )
    Object.entries(catalog).forEach(([ns, resources]) =>
      i18n.addResourceBundle(locale, ns, resources)
    )
    loadedCatalogs.set(locale, url)
  } catch (e) {
    Sentry.captureException(e)
  }
}

export function localeIsReady(): boolean {
  const locale = pageLocale()
  if (i18n.language !== locale) return false
  if (locale === DEFAULT_LOCALE) return true

  const url = pageCatalogUrl()
  return !url || loadedCatalogs.get(locale) === url
}

// Turbo keeps this module alive between pages, so the language can change under it
export function ensureLocale(): Promise<void> {
  queue = queue.then(async () => {
    if (localeIsReady()) return

    const locale = pageLocale()
    const url = pageCatalogUrl()
    if (locale !== DEFAULT_LOCALE && url) await loadCatalog(locale, url)
    if (i18n.language !== locale) await i18n.changeLanguage(locale)
  })
  return queue
}

export function whenLocaleReady(callback: () => void): void {
  if (localeIsReady()) return callback()

  ensureLocale().then(callback)
}

export default i18n
