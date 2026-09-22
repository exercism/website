type Variant = {
  bare: string
  scripts?: Record<string, string>
  regions: Record<string, string>
  fallback: string
}

// Mirrors Locale::Normalize::VARIANTS
const VARIANTS: Record<string, Variant> = {
  es: {
    bare: 'es-419',
    regions: { ES: 'es-ES', '419': 'es-419' },
    fallback: 'es-419',
  },
  pt: { bare: 'pt-BR', regions: { BR: 'pt-BR' }, fallback: 'pt-PT' },
  zh: {
    bare: 'zh-CN',
    scripts: { Hans: 'zh-CN', Hant: 'zh-TW' },
    regions: { TW: 'zh-TW', HK: 'zh-TW', MO: 'zh-TW' },
    fallback: 'zh-CN',
  },
}

export function normalizeLocale(
  tag: string | null | undefined,
  locales: string[]
): string | null {
  const subtags = String(tag ?? '')
    .replace(/_/g, '-')
    .split('-')
  const language = (subtags[0] || '').toLowerCase()
  if (!language) return null

  const rest = subtags.slice(1)
  const script = capitalize(rest.find((s) => /^[A-Za-z]{4}$/.test(s)))
  const region = rest
    .find((s) => /^([A-Za-z]{2}|\d{3})$/.test(s))
    ?.toUpperCase()

  const candidates = [
    region ? `${language}-${region}` : language,
    variantFor(language, region, script, locales),
    language,
  ]

  return candidates.find((l) => l && locales.includes(l)) || null
}

export function resolveLocale(
  tags: readonly string[],
  locales: string[]
): string | null {
  for (const tag of tags) {
    const locale = normalizeLocale(tag, locales)
    if (locale) return locale
  }

  return null
}

function variantFor(
  language: string,
  region: string | undefined,
  script: string | undefined,
  locales: string[]
): string | null {
  const config = VARIANTS[language]
  if (!config) return null
  if (!locales.some((l) => l.startsWith(`${language}-`))) return null

  const scripted = script ? config.scripts?.[script] : undefined
  if (scripted) return scripted
  if (region) return config.regions[region] ?? config.fallback

  return config.bare
}

function capitalize(value: string | undefined): string | undefined {
  if (!value) return undefined

  return value[0].toUpperCase() + value.slice(1).toLowerCase()
}
