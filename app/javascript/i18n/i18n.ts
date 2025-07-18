// i18n/index.ts

import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'

import enGithubSyncer from './en/settings/github-syncer'
import huGithubSyncer from './hu/settings/github-syncer'
import enExerciseWidget from './en/components-common-exercise-widget'

// Initialize i18n at module load
if (!i18n.isInitialized) {
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
          'components/common/exercise-widget': enExerciseWidget,
        },
        hu: {
          'settings/github-syncer': huGithubSyncer,
        },
      },
    })
}
