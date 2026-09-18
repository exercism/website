jest.mock('@sentry/react', () => ({
  captureMessage: jest.fn(),
  captureException: jest.fn(),
}))
jest.mock('@/i18n/en', () => ({
  __esModule: true,
  default: { 'test/ns': { hello: 'Hello', onlyEnglish: 'Only English' } },
}))
jest.mock('@/utils/locale-roster', () => ({
  DEFAULT_LOCALE: 'en',
  isProductionLocale: (locale: string) => ['en', 'hu'].includes(locale),
}))

const CATALOG_URL = '/i18n/hu/frontend-0123456789ab.json'

function setPage(locale: string | null, catalogUrl: string | null = null) {
  document.head.innerHTML = ''
  const add = (name: string, content: string) => {
    const meta = document.createElement('meta')
    meta.name = name
    meta.content = content
    document.head.appendChild(meta)
  }
  if (locale) add('exercism-locale', locale)
  if (catalogUrl) add('exercism-i18n-catalog', catalogUrl)
}

function mockCatalog(catalog: unknown, ok = true) {
  const fetchMock = jest.fn().mockResolvedValue({
    ok,
    status: ok ? 200 : 404,
    json: async () => catalog,
  })
  global.fetch = fetchMock as unknown as typeof fetch
  return fetchMock
}

// i18n.ts initialises on import, so each test loads a fresh copy
let Sentry: { captureMessage: jest.Mock; captureException: jest.Mock }

function loadModule(): typeof import('@/i18n/i18n') {
  jest.resetModules()
  Sentry = require('@sentry/react')
  return require('@/i18n/i18n')
}

test('english needs no catalog and is ready immediately', async () => {
  setPage(null)
  const fetchMock = mockCatalog({})
  const { default: i18n, localeIsReady, whenLocaleReady } = loadModule()

  expect(i18n.language).toBe('en')
  expect(localeIsReady()).toBe(true)

  const rendered = jest.fn()
  whenLocaleReady(rendered)
  expect(rendered).toHaveBeenCalledTimes(1)
  expect(fetchMock).not.toHaveBeenCalled()
  expect(i18n.t('hello', { ns: 'test/ns' })).toBe('Hello')
})

test('another locale is not pinned to english, and rendering waits for its catalog', async () => {
  setPage('hu', CATALOG_URL)
  const fetchMock = mockCatalog({ 'test/ns': { hello: 'Szia' } })
  const { default: i18n, localeIsReady, whenLocaleReady } = loadModule()

  expect(i18n.language).toBe('hu')
  expect(localeIsReady()).toBe(false)

  const rendered = jest.fn()
  whenLocaleReady(rendered)
  expect(rendered).not.toHaveBeenCalled()

  await new Promise((resolve) => whenLocaleReady(() => resolve(null)))
  expect(rendered).toHaveBeenCalledTimes(1)
  expect(fetchMock).toHaveBeenCalledTimes(1)
  expect(fetchMock).toHaveBeenCalledWith(CATALOG_URL)
  expect(i18n.t('hello', { ns: 'test/ns' })).toBe('Szia')
})

test('a turbo visit to another locale switches language explicitly', async () => {
  setPage(null)
  mockCatalog({ 'test/ns': { hello: 'Szia' } })
  const { default: i18n, ensureLocale } = loadModule()
  expect(i18n.t('hello', { ns: 'test/ns' })).toBe('Hello')

  setPage('hu', CATALOG_URL)
  await ensureLocale()
  expect(i18n.language).toBe('hu')
  expect(i18n.t('hello', { ns: 'test/ns' })).toBe('Szia')

  setPage(null)
  await ensureLocale()
  expect(i18n.language).toBe('en')
  expect(i18n.t('hello', { ns: 'test/ns' })).toBe('Hello')
})

test('a catalog is fetched once per url, and a new hash replaces the old one', async () => {
  setPage('hu', CATALOG_URL)
  const fetchMock = mockCatalog({ 'test/ns': { hello: 'Szia', gone: 'Volt' } })
  const { default: i18n, ensureLocale } = loadModule()

  await ensureLocale()
  await ensureLocale()
  expect(fetchMock).toHaveBeenCalledTimes(1)

  const newUrl = CATALOG_URL.replace('0123456789ab', 'ba9876543210')
  setPage('hu', newUrl)
  const secondFetch = mockCatalog({ 'test/ns': { hello: 'Szia!' } })
  await ensureLocale()

  expect(secondFetch).toHaveBeenCalledWith(newUrl)
  expect(i18n.t('hello', { ns: 'test/ns' })).toBe('Szia!')
  expect(
    i18n.exists('gone', { ns: 'test/ns', lng: 'hu', fallbackLng: [] })
  ).toBe(false)
})

test('a production locale falling back to english is reported, once', async () => {
  setPage('hu', CATALOG_URL)
  mockCatalog({ 'test/ns': { hello: 'Szia' } })
  const { default: i18n, ensureLocale } = loadModule()
  await ensureLocale()

  expect(i18n.t('onlyEnglish', { ns: 'test/ns' })).toBe('Only English')
  expect(i18n.t('onlyEnglish', { ns: 'test/ns' })).toBe('Only English')
  i18n.t('hello', { ns: 'test/ns' })

  expect(Sentry.captureMessage).toHaveBeenCalledTimes(1)
  expect(Sentry.captureMessage).toHaveBeenCalledWith(
    'Missing hu translation: test/ns:onlyEnglish',
    expect.objectContaining({ tags: { locale: 'hu' } })
  )
})

test('a key that exists nowhere is reported by the missing-key handler', async () => {
  setPage(null)
  const { default: i18n } = loadModule()

  i18n.t('nope', { ns: 'test/ns' })
  expect(Sentry.captureMessage).toHaveBeenCalledWith(
    'Unknown en translation: test/ns:nope',
    expect.anything()
  )
})

test('a catalog that fails to load still renders, in english, and says so', async () => {
  setPage('hu', CATALOG_URL)
  mockCatalog({}, false)
  const { default: i18n, whenLocaleReady } = loadModule()

  await new Promise((resolve) => whenLocaleReady(() => resolve(null)))
  expect(Sentry.captureException).toHaveBeenCalledTimes(1)
  expect(i18n.t('hello', { ns: 'test/ns' })).toBe('Hello')
})
