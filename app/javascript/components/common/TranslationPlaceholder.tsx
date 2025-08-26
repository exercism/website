import React, { useEffect } from 'react'
import { marked } from 'marked'
import { LocalizationTranslationChannel } from '@/channels/localizationTranslationChannel'
import Icon from './Icon'

// fallback
const languageNames: Record<string, string> = {
  en: 'English',
  fr: 'French',
  es: 'Spanish',
  de: 'German',
  it: 'Italian',
  pt: 'Portuguese',
  zh: 'Chinese',
  ja: 'Japanese',
  ko: 'Korean',
  ru: 'Russian',
  ar: 'Arabic',
  hi: 'Hindi',
  tr: 'Turkish',
  nl: 'Dutch',
  pl: 'Polish',
  sv: 'Swedish',
  no: 'Norwegian',
  da: 'Danish',
  fi: 'Finnish',
  cs: 'Czech',
  el: 'Greek',
  he: 'Hebrew',
  hu: 'Hungarian',
  ro: 'Romanian',
  uk: 'Ukrainian',
  id: 'Indonesian',
  vi: 'Vietnamese',
  th: 'Thai',
}

function getLanguageName(locale: string): string {
  console.log('LOCALE', locale)
  if (!locale) return 'selected language'

  const langCode = locale.toLowerCase().split('-')[0].replace('_', '-')

  try {
    const displayNames = new Intl.DisplayNames(['en'], { type: 'language' })
    const name = displayNames.of(langCode)
    if (name) return name
  } catch (e) {
    console.warn('Intl.DisplayNames is not supported in this environment.')
  }

  return languageNames[langCode] || locale
}

export type TranslationPlaceholderProps = {
  locale: string
  uuid: string
}

export default function TranslationPlaceholder({
  locale,
}: TranslationPlaceholderProps) {
  const languageName = getLanguageName(locale)

  const [translationValue, setTranslationValue] = React.useState<string | null>(
    null
  )

  useEffect(() => {
    const solutionChannel = new LocalizationTranslationChannel(
      locale,
      (response) => {
        console.log('Translation received', response)
        setTranslationValue(response.value)
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [])

  if (translationValue) {
    return (
      <div
        dangerouslySetInnerHTML={{ __html: marked.parse(translationValue) }}
      />
    )
  }

  return (
    <div
      role="status"
      className="flex items-center gap-2 w-full border-1 border-borderColor5 px-8 py-4 rounded-8 justify-between text-14"
    >
      <span>💬 Translating to {languageName}…</span>
      <Icon
        height={16}
        width={16}
        icon="spinner"
        alt="little spinner"
        className="animate-spin-slow filter-textColor6"
      />
    </div>
  )
}
