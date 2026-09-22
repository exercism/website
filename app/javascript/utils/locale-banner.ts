import { metaContent, pageLocale } from '@/utils/page-locale'
import { resolveLocale } from '@/utils/locale-resolve'
import { LOCALE_PREF_COOKIE } from '@/utils/locale-pref-cookie'

const DISMISS_KEY_PREFIX = 'locale-banner-dismissed:'
const BANNER_META = 'exercism-locale-banner'
const USER_META = 'user-id'

type LocaleCopy = {
  name: string
  dir: string
  path: string
  pre: string
  link: string
  dismiss: string
}

type Catalog = Record<string, LocaleCopy>

/**
 * "This page is in English. View it in magyar."
 *
 * A public page is cached by URL alone, so the offer is made here, against the
 * copy for every served locale that ships in the page. Dismissal is remembered
 * per offered language, so a visitor who turned down Hungarian is still offered
 * Spanish.
 */
export function initLocaleBanner(): void {
  if (typeof document === 'undefined') return

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', renderBanner, { once: true })
  } else {
    renderBanner()
  }
}

function renderBanner(): void {
  const offered = offer()
  if (!offered) return

  document.body.insertBefore(
    build(offered.locale, offered.copy),
    document.body.firstChild
  )
}

function offer(): { locale: string; copy: LocaleCopy } | null {
  if (metaContent(USER_META)) return null
  if (hasPrefCookie()) return null

  const catalog = readCatalog()
  if (!catalog) return null

  const locale = resolveLocale(browserLanguages(), Object.keys(catalog))
  if (!locale || locale === pageLocale()) return null
  if (dismissed(locale)) return null

  const copy = catalog[locale]
  return copy ? { locale, copy } : null
}

function build(locale: string, copy: LocaleCopy): HTMLElement {
  const banner = document.createElement('div')
  banner.className = 'c-locale-banner'
  banner.lang = locale
  banner.dir = copy.dir
  banner.setAttribute('data-locale-banner', locale)

  const pre = document.createElement('span')
  pre.textContent = copy.pre

  const link = document.createElement('a')
  link.setAttribute('href', copy.path)
  link.setAttribute('hreflang', locale)
  link.setAttribute('data-locale-pref', locale)
  link.textContent = copy.link

  const dismiss = document.createElement('button')
  dismiss.type = 'button'
  dismiss.className = 'dismiss'
  dismiss.setAttribute('data-locale-banner-dismiss', 'true')
  dismiss.textContent = copy.dismiss
  dismiss.addEventListener('click', () => {
    banner.hidden = true
    write(`${DISMISS_KEY_PREFIX}${locale}`)
  })

  banner.append(pre, link, dismiss)
  return banner
}

function readCatalog(): Catalog | null {
  const raw = metaContent(BANNER_META)
  if (!raw) return null

  try {
    return JSON.parse(raw) as Catalog
  } catch {
    return null
  }
}

function browserLanguages(): readonly string[] {
  if (typeof navigator === 'undefined') return []
  if (navigator.languages?.length) return navigator.languages

  return navigator.language ? [navigator.language] : []
}

function hasPrefCookie(): boolean {
  return document.cookie
    .split(';')
    .some((part) => part.trim().startsWith(`${LOCALE_PREF_COOKIE}=`))
}

function dismissed(locale: string): boolean {
  try {
    return window.localStorage.getItem(`${DISMISS_KEY_PREFIX}${locale}`) === '1'
  } catch {
    return false
  }
}

function write(key: string): void {
  try {
    window.localStorage.setItem(key, '1')
  } catch {
    // Storage disabled (private mode etc.) — the banner still closes for this view.
  }
}
