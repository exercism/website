// i18n.ts
import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import resources from '../../../i18n/javascript-copy'

// Compute namespaces from the resources so i18next knows they exist.
const namespaces = Object.keys(resources.en || {})

void i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    lng: 'en', // force plain en
    fallbackLng: 'en',
    supportedLngs: ['en'], // avoid en-US surprises
    nonExplicitSupportedLngs: true,
    load: 'languageOnly',
    debug: false,
    initImmediate: false, // synchronous in Node
    interpolation: { escapeValue: false },
    react: { useSuspense: false },
    resources, // ← unified resource bundle
    ns: namespaces, // ← make all namespaces visible
    defaultNS: namespaces.includes('translation')
      ? 'translation'
      : namespaces[0],
    returnNull: false,
  })

i18n.changeLanguage('en')

export default i18n
