const DISMISS_KEY_PREFIX = 'locale-banner-dismissed:'

/**
 * The banner is server-rendered, so the server cannot know it was dismissed:
 * it always sends it, and this hides it again. Dismissal is remembered per
 * offered language, so a visitor who turned down Hungarian is still offered
 * Spanish.
 */
export function initLocaleBanner(): void {
  if (typeof document === 'undefined') return

  const banner = document.querySelector<HTMLElement>('[data-locale-banner]')
  const offered = banner?.getAttribute('data-locale-banner')
  if (!banner || !offered) return

  const key = `${DISMISS_KEY_PREFIX}${offered}`

  if (read(key)) {
    banner.hidden = true
    return
  }

  banner
    .querySelector('[data-locale-banner-dismiss]')
    ?.addEventListener('click', () => {
      banner.hidden = true
      write(key)
    })
}

function read(key: string): boolean {
  try {
    return window.localStorage.getItem(key) === '1'
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
