import {
  DEFAULT_LOCALE,
  KNOWN_LOCALES,
  PRODUCTION_LOCALES,
  SERVED_LOCALES,
  WIP_LOCALES,
  isProductionLocale,
} from '@/utils/locale-roster'

test('english is the default and in production', () => {
  expect(DEFAULT_LOCALE).toBe('en')
  expect(isProductionLocale('en')).toBe(true)
})

test('hungarian is work in progress', () => {
  expect(KNOWN_LOCALES).toContain('hu')
  expect(WIP_LOCALES).toContain('hu')
  expect(isProductionLocale('hu')).toBe(false)
})

test('production and wip never overlap', () => {
  expect(PRODUCTION_LOCALES.filter((l) => WIP_LOCALES.includes(l))).toEqual([])
})

test('tests are served english only', () => {
  expect(SERVED_LOCALES).toEqual(['en'])
})
