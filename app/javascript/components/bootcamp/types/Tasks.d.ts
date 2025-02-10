declare type Task = {
  name: string
  instructionsHtml: string
  status: 'active' | 'completed' | 'inactive'
  projectType?: string
  testsType: TestsType
  tests: TaskTest[]
}

type TestsType = 'io' | 'state'

declare type TaskTest = {
  name: string
  slug: string
  data: any
  function?: string
  functions?: SetupFunction[]
  params?: string[]
  imageSlug?: string
  matcher?: string
  expected?: string
  checks?: ExpectCheck[]
  setupFunctions: SetupFunction[]
  descriptionHtml?: string
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
