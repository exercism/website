import { SubmissionTestsStatus } from '../types'

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
  aiHelp: string
  initialFiles: string
  lastIterationFiles: string
}

export type TestRunnerStatus = {
  track: boolean
  exercise: boolean
}

export type TestRunner = {
  averageTestDuration: number
  status?: TestRunnerStatus
}

export type TestRun = {
  uuid: number | null
  submissionUuid: string
  version: number
  status: TestRunStatus
  message: string
  messageHtml: string
  output: string
  outputHtml: string
  tests: Test[]
  highlightjsLanguage: string
  tasks: AssignmentTask[]
  links: {
    self: string
  }
}

export type Test = {
  name: string
  status: TestStatus
  testCode: string
  message: string
  messageHtml: string
  output: string
  outputHtml: string
  index?: number
  taskId?: number
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
  CANCELLED = 'cancelled',
}

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
  EMACS = 'emacs',
}

export type WrapSetting = 'off' | 'on'

export enum Themes {
  LIGHT = 'light',
  DARK = 'material-ocean',
}

export type TabBehavior = 'captured' | 'default'

export type Assignment = {
  overview: string
  generalHints: string[]
  tasks: AssignmentTask[]
}

export type AssignmentTask = {
  id: number
  title: string
  text: string
  hints: string[]
}

export type EditorSettings = {
  theme: Themes
  wrap: WrapSetting
  tabBehavior: TabBehavior
  keybindings: Keybindings
  tabSize: number
  useSoftTabs: boolean
}
