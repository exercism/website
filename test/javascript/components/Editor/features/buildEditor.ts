import { build } from '@jackfranklin/test-data-bot'
import { Props } from '../../../../../app/javascript/components/editor/Props'

const RequestOptions = {
  initialData: {
    iterations: [
      {
        uuid: 'c9503164-3220-4f14-a1f7-e4aa533d0a62',
        submissionUuid: '3237bdba-0a5b-478e-93f5-e1862e824bbe',
        idx: 1,
        status: 'untested',
        numEssentialAutomatedComments: 0,
        numActionableAutomatedComments: 0,
        numNonActionableAutomatedComments: 0,
        submissionMethod: 'cli',
        createdAt: '2023-03-16T11:58:58Z',
        testsStatus: 'not_queued',
        isPublished: false,
        isLatest: false,
        links: {
          self: 'http://local.exercism.io:3020/tracks/ruby/exercises/two-fer/iterations?idx=1',
          automatedFeedback:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/iterations/c9503164-3220-4f14-a1f7-e4aa533d0a62/automated_feedback',
          delete:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/iterations/c9503164-3220-4f14-a1f7-e4aa533d0a62',
          solution:
            'http://local.exercism.io:3020/tracks/ruby/exercises/two-fer',
          testRun:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/submissions/3237bdba-0a5b-478e-93f5-e1862e824bbe/test_run',
          files:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/submissions/3237bdba-0a5b-478e-93f5-e1862e824bbe/files',
        },
      },
      {
        uuid: '48e61042-03c1-476c-93b4-472b775587df',
        submissionUuid: 'b44122e0-30d0-446c-a320-b28a6c9ea599',
        idx: 2,
        status: 'untested',
        numEssentialAutomatedComments: 0,
        numActionableAutomatedComments: 0,
        numNonActionableAutomatedComments: 0,
        submissionMethod: 'cli',
        createdAt: '2023-03-16T11:58:58Z',
        testsStatus: 'not_queued',
        isPublished: false,
        isLatest: false,
        links: {
          self: 'http://local.exercism.io:3020/tracks/ruby/exercises/two-fer/iterations?idx=2',
          automatedFeedback:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/iterations/48e61042-03c1-476c-93b4-472b775587df/automated_feedback',
          delete:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/iterations/48e61042-03c1-476c-93b4-472b775587df',
          solution:
            'http://local.exercism.io:3020/tracks/ruby/exercises/two-fer',
          testRun:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/submissions/b44122e0-30d0-446c-a320-b28a6c9ea599/test_run',
          files:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/submissions/b44122e0-30d0-446c-a320-b28a6c9ea599/files',
        },
      },
      {
        uuid: '78de53b8354647c7b8c771d52e85004e',
        submissionUuid: 'f713a3755f4b4bb18a1ae8b5e0aef778',
        idx: 3,
        status: 'non_actionable_automated_feedback',
        numEssentialAutomatedComments: 0,
        numActionableAutomatedComments: 0,
        numNonActionableAutomatedComments: 1,
        submissionMethod: 'api',
        createdAt: '2023-03-27T13:55:31Z',
        testsStatus: 'passed',
        analyzerFeedback: {
          summary: null,
          comments: [],
        },
        isPublished: false,
        isLatest: true,
        links: {
          self: 'http://local.exercism.io:3020/tracks/ruby/exercises/two-fer/iterations?idx=3',
          automatedFeedback:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/iterations/78de53b8354647c7b8c771d52e85004e/automated_feedback',
          delete:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/iterations/78de53b8354647c7b8c771d52e85004e',
          solution:
            'http://local.exercism.io:3020/tracks/ruby/exercises/two-fer',
          testRun:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/submissions/f713a3755f4b4bb18a1ae8b5e0aef778/test_run',
          files:
            'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276/submissions/f713a3755f4b4bb18a1ae8b5e0aef778/files',
        },
      },
    ],
  },
  initialDataUpdatedAt: 1679927498,
}

export const buildEditor = build<Props>({
  fields: {
    timeout: 60000,
    solution: { uuid: '263a24259fa74f9db60f01c193008276' },
    defaultSubmissions: [],
    defaultFiles: [{ filename: 'lasagna.rb', content: 'class Lasagna' }],
    insidersStatus: 'active',
    chatgptUsage: { '3.5': 4, '4.0': 2 },
    defaultSettings: {},
    autosave: { saveInterval: 500000 },
    help: { html: '' },
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
    request: {
      endpoint:
        'http://local.exercism.io:3020/api/v2/solutions/263a24259fa74f9db60f01c193008276?sideload%5B%5D=iterations',
      options: RequestOptions,
    },
    features: { theme: true, keybindings: true },
    iteration: {
      analyzerFeedback: null,
      representerFeedback: {
        html: '<p>This is exemplar!</p>\n',
        author: {
          name: 'Aron Demeter',
          reputation: 56,
          avatarUrl: 'https://assets.exercism.org/placeholders/user-avatar.svg',
          profileUrl: 'http://local.exercism.io:3020/profiles/dem4ron',
        },
      },
    },
  },
})
