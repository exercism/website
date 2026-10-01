import '@testing-library/jest-dom/extend-expect'

import {
  fromNow,
  shortFromNow,
  durationFromSeconds,
  durationTimeElementFromSeconds,
} from '../../../app/javascript/utils/time'

function setPageLocale(locale: string) {
  document.head.innerHTML = `<meta name="exercism-locale" content="${locale}">`
}

afterEach(() => {
  document.head.innerHTML = ''
})

test('fromNow follows the page locale', () => {
  var time = new Date()
  time.setDate(time.getDate() - 800)

  setPageLocale('hu')
  expect(fromNow(time)).toEqual('2 éve')
})

test('shortFromNow follows the page locale', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)

  setPageLocale('hu')
  expect(shortFromNow(time)).toEqual('2 napja')
})

// The Hungarian review asked for numerals on the singular units, because these
// are quick references in a UI: "1 éve", not dayjs's default "egy éve".
test('shortFromNow uses numerals for singular units in Hungarian', () => {
  setPageLocale('hu')

  const daysAgo = (days: number) => {
    var time = new Date()
    time.setDate(time.getDate() - days)
    return shortFromNow(time)
  }

  expect(daysAgo(365)).toEqual('1 éve')
  expect(daysAgo(3 * 365)).toEqual('3 éve')
  expect(daysAgo(31)).toEqual('1 hónapja')
  expect(daysAgo(1)).toEqual('1 napja')
})

// German's plural is dative ("1 Jahren"), so it keeps dayjs's own singular.
test('shortFromNow keeps the reviewed wording for other locales', () => {
  var time = new Date()
  time.setDate(time.getDate() - 365)

  setPageLocale('de')
  expect(shortFromNow(time)).toEqual('vor einem Jahr')

  setPageLocale('fr')
  expect(shortFromNow(time)).toEqual('il y a un an')
})

// Ukrainian's plural entry is a function that parses the unit key it is given,
// and the region variants are spelled differently here than dayjs registers
// them, so every served locale is exercised.
test('shortFromNow localises every served locale', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)

  const served = [
    'hu',
    'el',
    'fr',
    'uk',
    'es-419',
    'pt-BR',
    'zh-CN',
    'ja',
    'hi',
    'es-ES',
    'ko',
    'it',
    'bn',
    'pt-PT',
    'de',
    'zh-TW',
    'fa',
    'ar',
  ]

  served.forEach((locale) => {
    setPageLocale(locale)
    expect(shortFromNow(time)).not.toEqual('2d ago')
  })

  setPageLocale('uk')
  expect(shortFromNow(time)).toEqual('2 дні тому')

  setPageLocale('pt-BR')
  expect(shortFromNow(time)).toEqual('há 2 dias')
})

test('shortFromNow stays compact in English', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)

  setPageLocale('en')
  expect(shortFromNow(time)).toEqual('2d ago')
})

test('fromNow', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)
  expect(fromNow(time)).toEqual('2 days ago')
})

test('shortFromNow for now future', () => {
  var time = new Date()
  time.setTime(time.getTime() + 1)
  expect(shortFromNow(time)).toEqual('now')
})

test('shortFromNow for minute future', () => {
  var time = new Date()
  time.setTime(time.getTime() + 1 * 60 * 1000)
  expect(shortFromNow(time)).toEqual('in 1m')
})

test('shortFromNow for now', () => {
  var time = new Date()
  time.setDate(time.getDate())
  expect(shortFromNow(time)).toEqual('now')
})

test('shortFromNow for 1hr', () => {
  var time = new Date()
  time.setTime(time.getTime() - 60 * 60 * 1000)
  expect(shortFromNow(time)).toEqual('1h ago')
})

test('shortFromNow for 1d', () => {
  var time = new Date()
  time.setDate(time.getDate() - 0.001)
  expect(shortFromNow(time)).toEqual('1d ago')
})

test('shortFromNow for 2d', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)
  expect(shortFromNow(time)).toEqual('2d ago')
})

test('shortFromNow for 2 months', () => {
  var time = new Date()
  time.setDate(time.getDate() - 60)
  expect(shortFromNow(time)).toEqual('2mo ago')
})

test('durationFromSeconds for 43 seconds', () => {
  expect(durationFromSeconds(43)).toEqual('43 seconds')
})

test('durationFromSeconds for 1 minute', () => {
  expect(durationFromSeconds(60 + 5)).toEqual('1 minute')
})

test('durationFromSeconds for 16 minutes', () => {
  expect(durationFromSeconds(60 * 15 + 5)).toEqual('15 minutes')
})

test('durationFromSeconds for 1 hour', () => {
  expect(durationFromSeconds(60 * 60)).toEqual('1 hour')
})

test('durationFromSeconds for 1 day', () => {
  expect(durationFromSeconds(60 * 60 * 24)).toEqual('1 day')
})

test('durationFromSeconds for 2 days', () => {
  expect(durationFromSeconds(60 * 60 * 24 * 2)).toEqual('2 days')
})

test('durationFromSeconds for 1 month', () => {
  expect(durationFromSeconds(60 * 60 * 24 * 35)).toEqual('1 month')
})

test('durationFromSeconds for 2 months', () => {
  expect(durationFromSeconds(60 * 60 * 24 * 70)).toEqual('2 months')
})

test('durationTimeElementFromSeconds for 1 second', () => {
  expect(durationTimeElementFromSeconds(1)).toEqual('P 0D 0H 0M 1S')
})

test('durationTimeElementFromSeconds for 2 seconds', () => {
  expect(durationTimeElementFromSeconds(2)).toEqual('P 0D 0H 0M 2S')
})

test('durationTimeElementFromSeconds for 1 minute', () => {
  expect(durationTimeElementFromSeconds(60)).toEqual('P 0D 0H 1M 0S')
})

test('durationTimeElementFromSeconds for 2 minutes', () => {
  expect(durationTimeElementFromSeconds(60 * 2)).toEqual('P 0D 0H 2M 0S')
})

test('durationTimeElementFromSeconds for 1 hour', () => {
  expect(durationTimeElementFromSeconds(60 * 60)).toEqual('P 0D 1H 0M 0S')
})

test('durationTimeElementFromSeconds for 1 hour', () => {
  expect(durationTimeElementFromSeconds(60 * 60 * 2)).toEqual('P 0D 2H 0M 0S')
})

test('durationTimeElementFromSeconds for 1 day', () => {
  expect(durationTimeElementFromSeconds(60 * 60 * 24)).toEqual('P 1D 0H 0M 0S')
})

test('durationTimeElementFromSeconds for 2 days', () => {
  expect(durationTimeElementFromSeconds(60 * 60 * 24 * 2)).toEqual(
    'P 2D 0H 0M 0S'
  )
})

test('durationTimeElementFromSeconds for combination', () => {
  expect(
    durationTimeElementFromSeconds(
      60 * 60 * 24 * 2 + 60 * 60 * 3 + 60 * 22 + 55
    )
  ).toEqual('P 2D 3H 22M 55S')
})
