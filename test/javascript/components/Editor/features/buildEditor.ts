import { build } from '@jackfranklin/test-data-bot'
import { Props } from '../../../../../app/javascript/components/editor/Props'

export const buildEditor = build<Props>({
  fields: {
    timeout: 60000,
    defaultSubmissions: [],
    defaultFiles: [{ filename: 'lasagna.rb', content: 'class Lasagna' }],
    insidersStatus: 'active',
    chatgptUsage: { '3.5': 4, '4.0': 2 },
    defaultSettings: {},
    autosave: { saveInterval: 500000 },
    panels: {
      instructions: {
        assignment: {
          overview: '',
          generalHints: [],
          tasks: [],
        },
      },
      results: {
        testRunner: {
          averageTestDuration: 3,
        },
      },
      chatgptUsage: { '3.5': 4, '4.0': 2 },
    },
    track: {},
    exercise: {},
    links: {
      runTests: 'https://exercism.test/submissions',
      back: '',
    },
    features: { theme: true, keybindings: true },
    iteration: {
      analyzerFeedback: null,
      representerFeedback: {
        html: '<p>This is exemplar!</p>\n',
        author: {
          name: 'Aron Demeter',
          reputation: 56,
          avatarUrl:
            'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
          profileUrl: 'http://local.exercism.io:3020/profiles/dem4ron',
        },
      },
    },
  },
})
