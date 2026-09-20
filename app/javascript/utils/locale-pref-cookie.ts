export const LOCALE_PREF_COOKIE = '_exercism_locale_pref'

const ONE_YEAR = 60 * 60 * 24 * 365

/**
 * Records that the visitor *chose* this locale, so we stop inferring one for
 * them.
 *
 * Written before navigating, not after arriving: the redirect that sends a
 * first-time visitor to their language is decided before the destination page
 * renders, so a cookie written on arrival has already been bounced back past.
 * `document.cookie` is synchronous, so setting it in the click handler puts it
 * on the very request the click makes.
 */
export function setLocalePrefCookie(locale: string): void {
  if (typeof document === 'undefined') return

  document.cookie = `${LOCALE_PREF_COOKIE}=${locale}; path=/; max-age=${ONE_YEAR}; samesite=lax`
}

/**
 * The header switcher and the locale banner are both server-rendered plain
 * anchors, so one delegated listener covers every page, including the ones
 * that load no React.
 */
export function initLocalePrefLinks(): void {
  if (typeof document === 'undefined') return

  document.addEventListener('click', (event) => {
    const target = event.target
    if (!(target instanceof Element)) return

    const link = target.closest('[data-locale-pref]')
    const locale = link?.getAttribute('data-locale-pref')
    if (locale) setLocalePrefCookie(locale)
  })
}
