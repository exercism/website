export type Submission = {
  testsStatus: SubmissionTestsStatus
  uuid: string
  links: SubmissionLinks
  testRun?: TestRun
}

type SubmissionLinks = {
  cancel: string
  submit: string
  testRun: string
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

export type TestRun = {
  id: number | null
  submissionUuid: string
  status: TestRunStatus
  message: string
  tests: Test[]
}

export type Test = {
  name: string
  status: TestStatus
  testCode: string
  message: string
  output: string
}

export enum TestStatus {
  PASS = 'pass',
  FAIL = 'fail',
  ERROR = 'error',
}

export enum TestRunStatus {
  PASS = 'pass',
  FAIL = 'fail',
  ERROR = 'error',
  OPS_ERROR = 'ops_error',
  QUEUED = 'queued',
  TIMEOUT = 'timeout',
  CANCELLING = 'cancelling',
  CANCELLED = 'cancelled',
}

export type File = {
  filename: string
  content: string
}

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
  EMACS = 'emacs',
}

export type WrapSetting = 'off' | 'on' | 'wordWrapColumn' | 'bounded'
