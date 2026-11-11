import {
  SIGNUP_ATTRIBUTION_COOKIE,
  captureSignupAttribution,
} from '@/utils/signup-attribution'

function readAttribution(): Record<string, string> | null {
  const cookie = document.cookie
    .split(';')
    .map((part) => part.trim())
    .find((part) => part.startsWith(`${SIGNUP_ATTRIBUTION_COOKIE}=`))
  if (!cookie) return null

  return JSON.parse(
    decodeURIComponent(cookie.slice(SIGNUP_ATTRIBUTION_COOKIE.length + 1))
  )
}

function setReferrer(value: string) {
  Object.defineProperty(document, 'referrer', {
    configurable: true,
    value,
  })
}

beforeEach(() => {
  document.cookie = `${SIGNUP_ATTRIBUTION_COOKIE}=; path=/; max-age=0`
  setReferrer('')
})

test('records the landing path, UTM parameters and external referrer', () => {
  window.history.pushState(
    {},
    '',
    '/tracks/ruby?utm_source=newsletter&utm_campaign=launch&reset_password_token=secret'
  )
  setReferrer('https://www.google.com/search?q=exercism')

  captureSignupAttribution()

  expect(readAttribution()).toEqual({
    referrer: 'https://www.google.com/search',
    landing_path: '/tracks/ruby',
    utm_source: 'newsletter',
    utm_campaign: 'launch',
  })
})

test('ignores a referrer from this site', () => {
  window.history.pushState({}, '', '/tracks')
  setReferrer(`${window.location.origin}/dashboard`)

  captureSignupAttribution()

  expect(readAttribution()).toEqual({ landing_path: '/tracks' })
})

test('keeps the first touch', () => {
  window.history.pushState({}, '', '/first?utm_source=first')
  captureSignupAttribution()

  window.history.pushState({}, '', '/second?utm_source=second')
  captureSignupAttribution()

  expect(readAttribution()).toEqual({
    landing_path: '/first',
    utm_source: 'first',
  })
})
