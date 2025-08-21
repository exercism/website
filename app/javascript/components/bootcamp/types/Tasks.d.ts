declare type Task = {
  name: string
  instructionsHtml: string
  status: 'active' | 'completed' | 'inactive'
  projectType?: string
  testsType: TestsType
  tests: TaskTest[]
  bonus?: boolean
}

type TestsType = 'io' | 'state'

declare type TaskTest = {
  name: string
  slug: string
  data: any
  imageSlug?: string
  codeRun?: string
  function?: string
  expression?: string
  args?: any[]
  type?: TestsType
  checks?: ExpectCheck[]
  setupFunctions: SetupFunction[]
  descriptionHtml?: string
}

declare type ExpectCheck =
  | ExpectCheckProperty
  | ExpectCheckFunction
  | ExpectCheckReturn
declare type ExpectCheckProperty = {
  property: string
  value?: any
  matcher?: AvailableMatchers
  errorHtml?: string
  codeRun?: string
}
declare type ExpectCheckFunction = {
  function: string
  args?: any[]
  value?: any
  matcher?: AvailableMatchers
  errorHtml?: string
  codeRun?: string
}
declare type ExpectCheckReturn = {
  value: any
  matcher?: AvailableMatchers
  errorHtml?: string
}

type SetupFunction = [functionName: keyof Exercise, params?: any[]]
