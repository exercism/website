import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
import AdvancedFormat from 'dayjs/plugin/advancedFormat'
import en from 'dayjs/locale/en'
import { DEFAULT_LOCALE, pageLocale } from '@/utils/page-locale'

dayjs.extend(RelativeTime)
dayjs.extend(AdvancedFormat)

// Imported statically so esbuild bundles them. Add a locale here when it is
// added to config/i18n.json's `served`; dayjs ships English built in.
// dayjs lowercases the name it is given and falls back to the part before the
// first `-`, so es-419 and es-ES read `es`, pt-PT reads `pt`, and pt-BR and
// zh-CN read their own files.
import 'dayjs/locale/ar'
import 'dayjs/locale/bn'
import 'dayjs/locale/de'
import 'dayjs/locale/el'
import 'dayjs/locale/es'
import 'dayjs/locale/fa'
import 'dayjs/locale/fr'
import 'dayjs/locale/hi'
import 'dayjs/locale/hu'
import 'dayjs/locale/it'
import 'dayjs/locale/ja'
import 'dayjs/locale/ko'
import 'dayjs/locale/pt'
import 'dayjs/locale/pt-br'
import 'dayjs/locale/uk'
import 'dayjs/locale/zh-cn'
import 'dayjs/locale/zh-tw'

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

// Most locales spell the number out in the singular ("egy éve", "un anno fa").
// These are quick reference timestamps in chrome, so a numeral reads better and
// stays narrower. A locale's own plural template already carries the right
// wording, so `1` is substituted into it rather than a translation being
// invented here -- but only where that form is grammatically correct at one.
// German is the counter-example: its plural is dative ("1 Jahren"), so it is
// left on dayjs's singular ("vor einem Jahr"). Add a locale here once a native
// speaker has confirmed it; the default is dayjs's own reviewed wording.
const NUMERAL_SINGULAR_LOCALES = ['hu', 'uk']

const SINGULAR_UNITS = { y: 'yy', M: 'MM', d: 'dd', h: 'hh', m: 'mm' } as const

// dayjs takes relativeTime entries as either a template string or a function,
// so the plural entry is resolved through both shapes. The function form is
// given its own key, which locales such as Ukrainian parse.
function numeralSingular(plural: unknown, key: string): string | undefined {
  if (typeof plural === 'function') return plural(1, false, key, false)
  if (typeof plural === 'string') return plural.replace('%d', '1')

  return undefined
}

// Built once per locale, on first use, then cached.
const numeralLocales = new Map<string, string>()

function numeralLocaleFor(locale: string): string {
  const cached = numeralLocales.get(locale)
  if (cached) return cached

  const base = dayjs.Ls[locale.toLowerCase()]

  // Registering a name dayjs doesn't know would fall back to English, so an
  // unexpected locale keeps its own (correct, if word-form) relative time.
  if (!base?.relativeTime) {
    numeralLocales.set(locale, locale)

    return locale
  }

  const name = `${locale}-numeral`
  const relativeTime = { ...base.relativeTime }

  Object.entries(SINGULAR_UNITS).forEach(([singular, plural]) => {
    const form = numeralSingular(
      relativeTime[plural as keyof typeof relativeTime],
      plural
    )
    if (form) {
      // @ts-expect-error -- indexed by the unit keys above, which are all valid.
      relativeTime[singular] = form
    }
  })

  dayjs.locale({ ...base, name, relativeTime }, null, true)
  numeralLocales.set(locale, name)

  return name
}

/**
 * Compact relative time. English keeps the abbreviated form ("2d ago"); every
 * other locale gets its own relative time ("2 napja"), because the
 * abbreviations are English words that translators have no key to fix.
 */
export function shortRelative(dateTime?: dayjs.ConfigType): string {
  const locale = pageLocale()

  if (locale !== DEFAULT_LOCALE) {
    const short = NUMERAL_SINGULAR_LOCALES.includes(locale)
      ? numeralLocaleFor(locale)
      : locale

    return dayjs(dateTime).locale(short).fromNow()
  }

  const relative = dayjs(dateTime).locale(SHORT_LOCALE).fromNow()

  return relative.includes(NOW) ? 'now' : relative
}

export default dayjs
