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
  numComments: 10,
  unread: false,
  numEssentialAutomatedComments: 2,
  numActionableAutomatedComments: 2,
  numNonActionableAutomatedComments: 2,
  submissionMethod: SubmissionMethod.API,
  createdAt: new Date().toISOString(),
  testsStatus: SubmissionTestsStatus.PASSED,
  isPublished: false,
  links: {
    self: 'https://test.exercism.io/iterations/1',
    solution: 'https://test.exercism.io/iterations/1/solution',
    files: 'https://test.exercism.io/iterations/1/files',
  },
  ...props,
})
