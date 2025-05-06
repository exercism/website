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
  normalizeCss: string
  default: {
    html?: string
    css?: string
  }

  shouldHideCssEditor: boolean
  shouldHideHtmlEditor: boolean
  aspectRatio: number
  storedAt: string | null
  readonlyRanges?: HtmlCssReadonlyRanges
  defaultReadonlyRanges?: HtmlCssReadonlyRanges
}

type HtmlCssReadonlyRanges = { html: ReadonlyRange[]; css: ReadonlyRange[] }

type ReadonlyRange = {
  from: number
  to: number
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
  cssChecks: Check[]
  htmlChecks: Check[]
}

type Check = {
  function: string
  matcher: 'toBeTrue' | 'toBeFalse'
  errorHtml: string
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
