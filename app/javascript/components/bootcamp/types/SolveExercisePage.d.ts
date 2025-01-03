type Code = {
  stub: string
  code: string
  stored_at: Date | string | null
  readonlyRanges: { from: number; to: number }[]
}

type Solution = {
  uuid: string
  status: 'completed' | 'in_progress'
}

interface Exercise {
  part: number
  introductionHtml: string
  config: Config
  tasks: Task[]
  testResults: Pick<TestSuiteResult<NewTestResult>, 'status'> & {
    tests: (Pick<NewTestResult, 'status' | 'slug'> & { actual: string })[]
  }
}

type Project = { slug: string }

declare type SolveExercisePageProps = {
  solution: Solution
  project: Project
  exercise: Exercise
  code: Code
  links: {
    postSubmission: string
    completeSolution: string
    projectsIndex: string
    dashboardIndex: string
  }
}

declare type Config = {
  description: string
  title: string
  projectType: string
  // tasks: Task[];
  testsType: 'io' | 'state'
}
