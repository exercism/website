import i18next from 'i18next'
import i18n from 'i18next'
// import resourcesToBackend from "i18next-resources-to-backend";

const DEFAULT_LANGUAGE = 'en'
const DEBUG = false

import enLangPack from './locales/en/translation.json'
import nlLangPack from './locales/nl/translation.json'
import systemLangPack from './locales/system/translation.json'

i18n.init({
  debug: DEBUG,
  lng: DEFAULT_LANGUAGE,
  initImmediate: false,
})
i18next.addResourceBundle('system', 'translation', systemLangPack)
i18next.addResourceBundle('en', 'translation', enLangPack)
i18next.addResourceBundle('nl', 'translation', nlLangPack)

export function getLanguage(): string {
  return i18next.language
}

export async function changeLanguage(language: string): Promise<void> {
  if (i18next.language === language) return

  await i18next.changeLanguage(language)
}

export function translate(key: string, options = {}): string {
  return i18next
    .t(key, { ...options, interpolation: { escapeValue: false } })
    .toString()
}
