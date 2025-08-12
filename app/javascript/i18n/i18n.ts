import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'

import Backend from 'i18next-http-backend'

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

export default i18n