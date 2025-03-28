type CSSExercisePageProps = {
  solution: CSSExercisePageSolution
  project: Project
  exercise: CSSExercisePageExercise
  code: CSSExercisePageCode
  links: {
    postSubmission: string
    completeSolution: string
    projectsIndex: string
    dashboardIndex: string
    bootcampLevelUrl: string
    updateCustomFns?: string
    customFnsDashboard?: string
    deleteCustomFn?: string
  }
}

type CSSExercisePageCode = {
  stub: { html: string; css: string }
  code: string
  storedAt: string | null
  readonlyRanges?: { from: number; to: number }[]
  defaultReadonlyRanges?: { from: number; to: number }[]
}

type CSSExercisePageSolution = {
  uuid: string
  status: 'completed' | 'in_progress'
  passedBasicTests: boolean
}

interface CSSExercisePageExercise {
  config: CSSExercisePageConfig
  id: number
  introductionHtml: string
  slug: string
  title: string
}

type CSSExercisePageConfig = {
  title: string
  description: string
  allowedPorperties: string[] | null
  disallowedPorperties: string[] | null
  projectType: string
  expected: {
    html: string
    css: string
  }
}
