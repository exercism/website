import {
  Iteration,
  IterationStatus,
  SubmissionMethod,
  SubmissionTestsStatus,
} from '../../../app/javascript/components/types'

export const createIteration = (props: Partial<Iteration>): Iteration => ({
  uuid: 'uuid',
  idx: 1,
  status: IterationStatus.NO_AUTOMATED_FEEDBACK,
  unread: false,
  numEssentialAutomatedComments: 2,
  numActionableAutomatedComments: 2,
  numNonActionableAutomatedComments: 2,
  submissionMethod: SubmissionMethod.API,
  createdAt: new Date().toISOString(),
  testsStatus: SubmissionTestsStatus.PASSED,
  isPublished: false,
  posts: undefined,
  links: {
    self: 'https://test.exercism.org/iterations/1',
    solution: 'https://test.exercism.org/iterations/1/solution',
    files: 'https://test.exercism.org/iterations/1/files',
    testRun: 'https://test.exercism.org/iterations/1/test_run',
  },
  ...props,
})
