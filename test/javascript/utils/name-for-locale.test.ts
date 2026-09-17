import { nameForLocale } from '@/utils/name-for-locale'

test('names a language in itself, capitalised', () => {
  expect(nameForLocale('hu')).toBe('Magyar')
  expect(nameForLocale('en')).toBe('English')
})

test('can name a language in english', () => {
  expect(nameForLocale('hu', { displayInEnglish: true })).toBe('Hungarian')
})

test('regional variants keep their region', () => {
  expect(nameForLocale('pt-BR', { displayInEnglish: true })).toBe(
    'Brazilian Portuguese'
  )
  expect(nameForLocale('es-419', { displayInEnglish: true })).toBe(
    'Latin American Spanish'
  )
  expect(nameForLocale('pt-BR')).not.toBe(nameForLocale('pt-PT'))
})

test('falls back to the code for junk', () => {
  expect(nameForLocale('not a locale')).toBe('not a locale')
})
