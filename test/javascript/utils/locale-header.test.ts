jest.mock('@/utils/locale-roster', () => ({
  DEFAULT_LOCALE: 'en',
  isProductionLocale: (locale: string) => ['en', 'hu'].includes(locale),
}))

import { localeHeaders, LOCALE_HEADER } from '@/utils/locale-header'
import { fetchJSON } from '@/utils/fetch-json'

function setLocale(locale: string | null) {
  document.head.innerHTML = ''
  if (!locale) return

  const meta = document.createElement('meta')
  meta.name = 'exercism-locale'
  meta.content = locale
  document.head.appendChild(meta)
}

describe('localeHeaders', () => {
  test('is empty without the meta tag', () => {
    setLocale(null)

    expect(localeHeaders('/api/v2/notifications')).toEqual({})
  })

  test('carries the page locale on a relative url', () => {
    setLocale('hu')

    expect(localeHeaders('/api/v2/notifications')).toEqual({
      [LOCALE_HEADER]: 'hu',
    })
  })

  test('carries the page locale on a same-origin url', () => {
    setLocale('hu')

    expect(
      localeHeaders(`${window.location.origin}/api/v2/reputation`)
    ).toEqual({ [LOCALE_HEADER]: 'hu' })
  })

  test('is empty for another origin', () => {
    setLocale('hu')

    expect(localeHeaders('https://example.com/api/v2/notifications')).toEqual(
      {}
    )
  })

  test('is empty for an unparseable url', () => {
    setLocale('hu')

    expect(localeHeaders('http://[')).toEqual({})
  })
})

describe('fetchJSON', () => {
  test('sends the page locale', async () => {
    setLocale('hu')
    const fetchMock = jest.fn().mockResolvedValue({
      ok: true,
      headers: { get: () => 'application/json' },
      json: async () => ({}),
    })
    global.fetch = fetchMock as unknown as typeof fetch

    await fetchJSON('/api/v2/notifications', { method: 'GET' })

    expect(fetchMock.mock.calls[0][1].headers[LOCALE_HEADER]).toBe('hu')
  })

  test('sends no locale without the meta tag', async () => {
    setLocale(null)
    const fetchMock = jest.fn().mockResolvedValue({
      ok: true,
      headers: { get: () => 'application/json' },
      json: async () => ({}),
    })
    global.fetch = fetchMock as unknown as typeof fetch

    await fetchJSON('/api/v2/notifications', { method: 'GET' })

    expect(fetchMock.mock.calls[0][1].headers[LOCALE_HEADER]).toBeUndefined()
  })
})
