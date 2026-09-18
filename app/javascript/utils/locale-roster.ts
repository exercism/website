import roster from '../../../config/locale_roster.json'

type Status = 'production' | 'wip' | 'planned'

const locales = roster.locales as { code: string; status: Status }[]
const withStatus = (status: Status) =>
  locales.filter((l) => l.status === status).map((l) => l.code)

export const DEFAULT_LOCALE = roster.default
export const KNOWN_LOCALES = locales.map((l) => l.code)
export const PRODUCTION_LOCALES = withStatus('production')
export const WIP_LOCALES = withStatus('wip')

export const SERVED_LOCALES =
  process.env.NODE_ENV === 'test'
    ? [DEFAULT_LOCALE]
    : [...PRODUCTION_LOCALES, ...WIP_LOCALES]

export const isKnownLocale = (locale: string) => KNOWN_LOCALES.includes(locale)
export const isProductionLocale = (locale: string) =>
  PRODUCTION_LOCALES.includes(locale)
