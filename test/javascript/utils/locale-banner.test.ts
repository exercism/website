import { initLocaleBanner } from '@/utils/locale-banner'

const CATALOG = {
  en: {
    name: 'English',
    dir: 'ltr',
    path: '/tracks',
    pre: 'This page is in English.',
    link: 'View it in English',
    dismiss: 'Dismiss',
  },
  hu: {
    name: 'magyar',
    dir: 'ltr',
    path: '/hu/tracks',
    pre: 'Ez az oldal English nyelvű.',
    link: 'Megtekintés magyar nyelven',
    dismiss: 'Elvetés',
  },
}

function setUpPage({
  locale = 'en',
  userId = null,
  catalog = CATALOG as unknown,
}: {
  locale?: string
  userId?: string | null
  catalog?: unknown
} = {}) {
  document.head.innerHTML = [
    `<meta name="exercism-locale" content="${locale}">`,
    `<meta name="user-id"${userId ? ` content="${userId}"` : ''}>`,
    catalog
      ? `<meta name="exercism-locale-banner" content='${JSON.stringify(
          catalog
        )}'>`
      : '',
  ].join('')
  document.body.innerHTML = '<header></header>'
}

function setLanguages(languages: string[]) {
  Object.defineProperty(window.navigator, 'languages', {
    value: languages,
    configurable: true,
  })
  Object.defineProperty(window.navigator, 'language', {
    value: languages[0] || '',
    configurable: true,
  })
}

const banner = () => document.querySelector<HTMLElement>('[data-locale-banner]')

beforeEach(() => {
  window.localStorage.clear()
  document.cookie = '_exercism_locale_pref=; max-age=0; path=/'
  setLanguages(['hu-HU', 'en'])
  setUpPage()
})

test('a hungarian browser on an english page is offered hungarian', () => {
  initLocaleBanner()

  expect(banner()).not.toBeNull()
  expect(banner()!.getAttribute('data-locale-banner')).toBe('hu')
  expect(banner()).toBe(document.body.firstChild)
  expect(banner()!.textContent).toContain('Ez az oldal English nyelvű.')

  const link = banner()!.querySelector('a')!
  expect(link.getAttribute('href')).toBe('/hu/tracks')
  expect(link.getAttribute('data-locale-pref')).toBe('hu')
  expect(link.textContent).toBe('Megtekintés magyar nyelven')
})

test('no banner for a signed-in user', () => {
  setUpPage({ userId: '17' })
  initLocaleBanner()

  expect(banner()).toBeNull()
})

test('no banner once a preference cookie is set', () => {
  document.cookie = '_exercism_locale_pref=en; path=/'
  initLocaleBanner()

  expect(banner()).toBeNull()
})

test('no banner when the page is already in that language', () => {
  setUpPage({ locale: 'hu' })
  initLocaleBanner()

  expect(banner()).toBeNull()
})

test('no banner when no served locale matches the browser', () => {
  setLanguages(['de-DE', 'nl'])
  initLocaleBanner()

  expect(banner()).toBeNull()
})

test('no banner for a client with no languages', () => {
  setLanguages([])
  initLocaleBanner()

  expect(banner()).toBeNull()
})

test('no banner without the catalog', () => {
  setUpPage({ catalog: null })
  initLocaleBanner()

  expect(banner()).toBeNull()
})

test('dismissing hides the banner and remembers it', () => {
  initLocaleBanner()
  banner()!
    .querySelector<HTMLButtonElement>('[data-locale-banner-dismiss]')!
    .click()

  expect(banner()!.hidden).toBe(true)

  setUpPage()
  initLocaleBanner()

  expect(banner()).toBeNull()
})

test('dismissal is remembered per offered language', () => {
  window.localStorage.setItem('locale-banner-dismissed:es-419', '1')
  initLocaleBanner()

  expect(banner()!.getAttribute('data-locale-banner')).toBe('hu')
})
