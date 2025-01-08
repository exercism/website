/**
 * Result after running `generateAndRunTestSuite`
 */
declare type TestSuiteResult<Result> = {
  suiteName: string
  tests: Result[]
  status: 'pass' | 'fail'
}

/**
 * Result of the `test` callback
 */
declare type NewTestResult = {
  name: string
  slug: string
  testIndex: number
  status: 'pass' | 'fail'
} & ReturnType<TestCallback>

declare type PreviousTestResult = {
  testIndex: number
  name: string
  slug: string
  status: 'pass' | 'fail'
  actual: string | null
  expected: string | undefined | null
  codeRun: string
  testsType: TestsType
  errorHtml?: string
}
