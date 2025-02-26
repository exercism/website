declare type Task = {
  name: string
  instructionsHtml: string
  status: 'active' | 'completed' | 'inactive'
  projectType?: string
  testsType: TestsType
  tests: TaskTest[]
  bonus?: boolean
}

type TestsType = 'io' | 'io/check' | 'state'

declare type TaskTest = {
  name: string
  slug: string
  data: any
  function: string
  params: string[]
  imageSlug?: string
  matcher?: string
  expected?: string
  checks?: ExpectCheck[]
  setupFunctions: SetupFunction[]
  descriptionHtml?: string
  check: {
    function: string
    expected: string
    matcher?: string
    errorHtml?: string
  }
}

declare type ExpectCheck = {
  name: string
  value?: any
  label?: string
  note?: string
  matcher?: AvailableMatchers
  errorHtml?: string
}

type SetupFunction = [functionName: keyof Exercise, params?: any[]]
