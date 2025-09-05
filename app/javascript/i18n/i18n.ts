// i18n.ts
import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import Backend from 'i18next-http-backend'

// Only present in tests (the file your Ruby script generates)
import resources from '@/i18n/en.aggregated.test' // { en: { 'components/notifications/': { ... }, ... } }

const isTest = process.env.NODE_ENV === 'test'

if (isTest) {
  // Compute namespaces from the aggregated file so i18next knows they exist.
  const namespaces = Object.keys((resources as any).en || {})

  void i18n.use(initReactI18next).init({
    lng: 'en', // force plain en
    fallbackLng: 'en',
    supportedLngs: ['en'], // avoid en-US surprises
    nonExplicitSupportedLngs: true,
    load: 'languageOnly',
    debug: false,
    initImmediate: false, // synchronous in Node
    interpolation: { escapeValue: false },
    react: { useSuspense: false }, // never suspend in tests
    resources, // ← aggregated bundle
    ns: namespaces, // ← make all test namespaces visible
    defaultNS: namespaces.includes('translation')
      ? 'translation'
      : namespaces[0],
    returnNull: false,
  })

  i18n.changeLanguage('en')
} else {
  void i18n
    .use(Backend)
    .use(LanguageDetector)
    .use(initReactI18next)
    .init({
      fallbackLng: 'en',
      debug: true,
      interpolation: { escapeValue: false },
      backend: { loadPath: '/javascript-i18n/foo/en.js' },
      react: { useSuspense: true },
    })
}

export default i18n
