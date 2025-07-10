import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'

import enGithubSyncer from './i18n/en/settings/github-syncer'
import huGithubSyncer from './i18n/hu/settings/github-syncer'

let isInitialized = false

export function initI18n() {
  if (isInitialized) return
  isInitialized = true

  i18n
    .use(LanguageDetector)
    .use(initReactI18next)
    .init({
      fallbackLng: 'en',
      lng: 'hu',
      debug: true,
      interpolation: {
        escapeValue: false,
      },
      resources: {
        en: {
          'settings/github-syncer': enGithubSyncer,
        },
        hu: {
          'settings/github-syncer': huGithubSyncer,
        },
      },
    })
}
