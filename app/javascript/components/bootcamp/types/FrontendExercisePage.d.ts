type FrontendExercisePageProps = {
  solution: FrontendExercisePageSolution
  project: Project
  exercise: FrontendExercisePageExercise
  code: FrontendExercisePageCode
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

type FrontendExercisePageCode = {
  stub: { html: string; css: string; js: string }
  code: string
  normalizeCss: string
  default: {
    html?: string
    css?: string
    js?: string
  }

  shouldHideCssEditor: boolean
  shouldHideHtmlEditor: boolean
  aspectRatio: number
  storedAt: string | null
  readonlyRanges?: HtmlCssJsReadonlyRanges
  defaultReadonlyRanges?: HtmlCssJsReadonlyRanges
}

type HtmlCssJsReadonlyRanges = {
  html: ReadonlyRange[]
  css: ReadonlyRange[]
  js: ReadonlyRange[]
}

type FrontendExercisePageSolution = {
  uuid: string
  status: 'completed' | 'in_progress'
  passedBasicTests: boolean
}

interface FrontendExercisePageExercise {
  config: FrontendExercisePageConfig
  id: number
  introductionHtml: string
  slug: string
  title: string
  cssChecks: Check[]
  htmlChecks: Check[]
}

type FrontendExercisePageConfig = {
  title: string
  description: string
  allowedPorperties: string[] | null
  disallowedPorperties: string[] | null
  projectType: string
  expected: {
    html: string
    css: string
    js: string
  }
}
