import { normalizeLocale, resolveLocale } from '@/utils/locale-resolve'

test('exact and case-insensitive matches', () => {
  expect(normalizeLocale('hu', ['en', 'hu'])).toBe('hu')
  expect(normalizeLocale('HU', ['en', 'hu'])).toBe('hu')
  expect(normalizeLocale('pt-br', ['en', 'pt-BR'])).toBe('pt-BR')
  expect(normalizeLocale('pt_BR', ['en', 'pt-BR'])).toBe('pt-BR')
})

test("a region we don't distinguish falls back to the language", () => {
  expect(normalizeLocale('hu-HU', ['en', 'hu'])).toBe('hu')
  expect(normalizeLocale('en-GB', ['en', 'hu'])).toBe('en')
  expect(normalizeLocale('es-419', ['en', 'es'])).toBe('es')
  expect(normalizeLocale('es-CL', ['en', 'es'])).toBe('es')
})

test('blank, junk and unserved tags are null', () => {
  expect(normalizeLocale(null, ['en', 'hu'])).toBeNull()
  expect(normalizeLocale('', ['en', 'hu'])).toBeNull()
  expect(normalizeLocale('*', ['en', 'hu'])).toBeNull()
  expect(normalizeLocale('de-DE', ['en', 'hu'])).toBeNull()
  expect(normalizeLocale('hungarian', ['en', 'hu'])).toBeNull()
})

test('spanish variants do not collapse', () => {
  const locales = ['en', 'es-419', 'es-ES']

  expect(normalizeLocale('es-419', locales)).toBe('es-419')
  expect(normalizeLocale('es-CL', locales)).toBe('es-419')
  expect(normalizeLocale('es-AR', locales)).toBe('es-419')
  expect(normalizeLocale('es-US', locales)).toBe('es-419')
  expect(normalizeLocale('es', locales)).toBe('es-419')
  expect(normalizeLocale('es-ES', locales)).toBe('es-ES')
  expect(normalizeLocale('es-es', locales)).toBe('es-ES')
})

test("a variant we don't ship is not swapped for its sibling", () => {
  expect(normalizeLocale('es-ES', ['en', 'es-419'])).toBeNull()
  expect(normalizeLocale('es-MX', ['en', 'es-419'])).toBe('es-419')
  expect(normalizeLocale('pt-PT', ['en', 'pt-BR'])).toBeNull()
})

test('portuguese variants', () => {
  const locales = ['en', 'pt-BR', 'pt-PT']

  expect(normalizeLocale('pt', locales)).toBe('pt-BR')
  expect(normalizeLocale('pt-BR', locales)).toBe('pt-BR')
  expect(normalizeLocale('pt-PT', locales)).toBe('pt-PT')
  expect(normalizeLocale('pt-AO', locales)).toBe('pt-PT')
})

test('chinese variants split by script, then region', () => {
  const locales = ['en', 'zh-CN', 'zh-TW']

  expect(normalizeLocale('zh', locales)).toBe('zh-CN')
  expect(normalizeLocale('zh-CN', locales)).toBe('zh-CN')
  expect(normalizeLocale('zh-SG', locales)).toBe('zh-CN')
  expect(normalizeLocale('zh-TW', locales)).toBe('zh-TW')
  expect(normalizeLocale('zh-HK', locales)).toBe('zh-TW')
  expect(normalizeLocale('zh-MO', locales)).toBe('zh-TW')
  expect(normalizeLocale('zh-Hant', locales)).toBe('zh-TW')
  expect(normalizeLocale('zh-Hant-HK', locales)).toBe('zh-TW')
  expect(normalizeLocale('zh-Hans-HK', locales)).toBe('zh-CN')
})

test('resolution takes the first supported language in order', () => {
  expect(resolveLocale(['de', 'hu-HU', 'en'], ['en', 'hu'])).toBe('hu')
  expect(resolveLocale(['de', 'nl'], ['en', 'hu'])).toBeNull()
  expect(resolveLocale([], ['en', 'hu'])).toBeNull()
})
