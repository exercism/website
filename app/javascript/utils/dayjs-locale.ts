import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
import AdvancedFormat from 'dayjs/plugin/advancedFormat'
import { DEFAULT_LOCALE, pageLocale } from '@/utils/page-locale'

dayjs.extend(RelativeTime)
dayjs.extend(AdvancedFormat)

// Statically required so esbuild bundles them; a dynamic path would not be
// resolvable at build time. Add a locale here when it is added to
// config/i18n.json's `served`.
import 'dayjs/locale/hu'
import en from 'dayjs/locale/en'

// dayjs ships English built in, so it has no entry above.
const SUPPORTED = new Set([DEFAULT_LOCALE, 'hu'])

/**
 * dayjs keeps one global locale, and Turbo keeps this module alive across
 * page loads, so the locale is re-read per call rather than set once.
 */
export function localisedDayjs(dateTime?: dayjs.ConfigType) {
  const locale = pageLocale()

  return dayjs(dateTime).locale(SUPPORTED.has(locale) ? locale : DEFAULT_LOCALE)
}

/**
 * A locale that renders relative times in the compact "2d ago" form. It is
 * derived from English rather than computed from a diff, so dayjs keeps
 * ownership of unit selection and rounding.
 *
 * Only the English short form exists: the abbreviations are not translated,
 * and shortFromNow's callers are chrome where they read as symbols.
 */
export const SHORT_LOCALE = 'en-short'

const NOW = '__now__'

dayjs.locale(
  {
    ...en,
    name: SHORT_LOCALE,
    relativeTime: {
      future: 'in %s',
      past: '%s ago',
      // dayjs wraps every result in past/future, so the sub-minute bucket is
      // tagged here and unwrapped by the caller.
      s: NOW,
      ss: NOW,
      m: '1m',
      mm: '%dm',
      h: '1h',
      hh: '%dh',
      d: '1d',
      dd: '%dd',
      M: '1mo',
      MM: '%dmo',
      y: '1y',
      yy: '%dy',
    },
  },
  null,
  true
)

export function shortRelative(dateTime?: dayjs.ConfigType): string {
  const relative = dayjs(dateTime).locale(SHORT_LOCALE).fromNow()

  return relative.includes(NOW) ? 'now' : relative
}

export default dayjs
