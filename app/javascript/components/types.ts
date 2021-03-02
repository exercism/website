export type File = {
  filename: string
  content: string
}

export type APIError = {
  type: string
  message: string
}

export type Iteration = {
  uuid: string
  idx: number
  status: IterationStatus
  numEssentialAutomatedComments: number
  numActionableAutomatedComments: number
  numNonActionableAutomatedComments: number
  submissionMethod: SubmissionMethod
  createdAt: Date
  testsStatus: SubmissionTestsStatus
  links: {
    self: string
  }
}

export enum SubmissionTestsStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  PASSED = 'passed',
  FAILED = 'failed',
  ERRORED = 'errored',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

export enum IterationStatus {
  TESTING = 'testing',
  TESTS_FAILED = 'tests_failed',
  ANALYZING = 'analyzing',
  ESSENTIAL_AUTOMATED_FEEDBACK = 'essential_automated_feedback',
  ACTIONABLE_AUTOMATED_FEEDBACK = 'actionable_automated_feedback',
  NON_ACTIONABLE_AUTOMATED_FEEDBACK = 'non_actionable_automated_feedback',
  NO_AUTOMATED_FEEDBACK = 'no_automated_feedback',
}

export enum SubmissionMethod {
  CLI = 'cli',
  API = 'api',
}

export enum RepresentationStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  APPROVED = 'approved',
  DISAPPROVED = 'disapproved',
  INCONCLUSIVE = 'inconclusive',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

export enum AnalysisStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  APPROVED = 'approved',
  DISAPPROVED = 'disapproved',
  INCONCLUSIVE = 'inconclusive',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}
