import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'

import en from './en'

// Initialize i18n at module load
if (!i18n.isInitialized) {
  i18n
    .use(LanguageDetector)
    .use(initReactI18next)
    .init({
      fallbackLng: 'en',
      lng: 'en',
      debug: true,
      interpolation: {
        escapeValue: false,
      },
      resources: {
        en,
      },
    })
}
