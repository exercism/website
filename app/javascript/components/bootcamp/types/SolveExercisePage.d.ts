import { LanguageFeatures } from '@/interpreter/interpreter'

declare global {
  type SolveExercisePageProps = {
    solution: Solution
    project: Project
    exercise: Exercise
    code: Code
    links: {
      postSubmission: string
      completeSolution: string
      projectsIndex: string
      dashboardIndex: string
      bootcampLevelUrl: string
      getCustomFns: string
      getCustomFnsForInterpreter: string
      updateCustomFns?: string
      customFnsDashboard?: string
    }
    customFunctions: CustomFunctionsFromServer
  }

  type CustomFunctionsFromServer = {
    selected: string[]
    forInterpreter: CustomFunctionForInterpreter[]
  }

  type CustomFunctionForInterpreter = {
    name: string
    arity: number
    code: string
    description: string
    dependencies: string[]
  }

  type Code = {
    stub: string
    code: string
    storedAt: Date | string | null
    readonlyRanges?: { from: number; to: number }[]
    defaultReadonlyRanges?: { from: number; to: number }[]
  }

  type Solution = {
    uuid: string
    status: 'completed' | 'in_progress'
    passedBasicTests: boolean
    passedBonusTests: boolean
  }

  interface Exercise {
    part: number
    title: string
    slug: string
    id: number
    introductionHtml: string
    config: Config
    tasks: Task[]
    testResults: Pick<TestSuiteResult<NewTestResult>, 'status'> & {
      tests: (Pick<NewTestResult, 'status' | 'slug'> & { actual: string })[]
    }
  }

  type Project = { slug: string }

  type Config = {
    description: string
    title: string
    projectType: string
    // tasks: Task[];
    testsType: 'io' | 'state'
    interpreterOptions: LanguageFeatures
    stdlibFunctions: string[]
    exerciseFunctions: string[]
  }
}
