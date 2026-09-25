import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
import AdvancedFormat from 'dayjs/plugin/advancedFormat'
import en from 'dayjs/locale/en'
import { pageLocale } from '@/utils/page-locale'

dayjs.extend(RelativeTime)
dayjs.extend(AdvancedFormat)

// Imported statically so esbuild bundles them. Add a locale here when it is
// added to config/i18n.json's `served`; dayjs ships English built in.
import 'dayjs/locale/el'
import 'dayjs/locale/fr'
import 'dayjs/locale/hu'
import 'dayjs/locale/uk'

// Turbo keeps this module alive across pages, so the locale is read per call.
// dayjs falls back to English for a locale that was never imported.
export const localisedDayjs = (dateTime?: dayjs.ConfigType) =>
  dayjs(dateTime).locale(pageLocale())

const SHORT_LOCALE = 'en-short'

// dayjs wraps every result in past/future, so "now" can't be expressed as a
// unit string and is tagged for the caller to unwrap.
const NOW = '__now__'

dayjs.locale(
  {
    ...en,
    name: SHORT_LOCALE,
    relativeTime: {
      future: 'in %s',
      past: '%s ago',
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

/**
 * Compact relative time ("2d ago"). English-only: the abbreviations aren't
 * translated, and the callers are chrome where they read as symbols.
 */
export function shortRelative(dateTime?: dayjs.ConfigType): string {
  const relative = dayjs(dateTime).locale(SHORT_LOCALE).fromNow()

  return relative.includes(NOW) ? 'now' : relative
}

export default dayjs
