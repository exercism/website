import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import Backend from 'i18next-http-backend'

import resources from '@/i18n/en.aggregated.test'
const isTest = process.env.NODE_ENV === 'test'

if (isTest) {
  void i18n.use(initReactI18next).init({
    lng: 'en',
    fallbackLng: 'en',
    debug: false,
    initImmediate: false,
    interpolation: { escapeValue: false },
    react: { useSuspense: false },
    resources,
  })
} else {
  void i18n
    .use(Backend)
    .use(LanguageDetector)
    .use(initReactI18next)
    .init({
      fallbackLng: 'en',
      debug: true,
      interpolation: { escapeValue: false },
      backend: {
        loadPath: '/javascript-i18n/foo/{{lng}}.js',
      },
      react: {
        useSuspense: true,
      },
    })
}

export default i18n
