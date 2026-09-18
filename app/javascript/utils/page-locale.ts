import { DEFAULT_LOCALE } from './locale-roster'

const LOCALE_META = 'exercism-locale'

export function metaContent(name: string): string | null {
  if (typeof document === 'undefined') return null

  return (
    document.querySelector(`meta[name="${name}"]`)?.getAttribute('content') ||
    null
  )
}

export const metaLocale = (): string | null => metaContent(LOCALE_META)

export const pageLocale = (): string => metaLocale() || DEFAULT_LOCALE
