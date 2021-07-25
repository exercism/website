import { build } from '@jackfranklin/test-data-bot'
import { Props } from '../../../../../app/javascript/components/Editor'

export const buildEditor = build<Props>({
  fields: {
    timeout: 60000,
    defaultSubmissions: [],
    defaultFiles: [{ filename: 'lasagna.rb', content: 'class Lasagna' }],
    defaultSettings: {},
    autosave: { saveInterval: 500000 },
    panels: {
      instructions: {
        assignment: {
          tasks: [],
        },
      },
    },
    track: {},
    exercise: {},
    links: {
      runTests: 'https://exercism.test/submissions',
      back: '',
    },
    features: { theme: true, keybindings: true },
  },
})
