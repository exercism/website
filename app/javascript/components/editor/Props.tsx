import { AnalyzerFeedback, File, RepresenterFeedback, TestFile } from '../types'
import { Submission, Assignment, EditorSettings } from './types'

export type EditorFeatures = {
  theme: boolean
  keybindings: boolean
}

export type TaskContext = {
  current: number | null
  switchToTask: (id: number) => void
  showJumpToInstructionButton: boolean
}

type Links = {
  runTests: string
  back: string
  automatedFeedbackInfoLink: string
}

type Track = {
  title: string
  slug: string
  iconUrl: string
}
type Iteration = {
  representerFeedback: RepresenterFeedback
  analyzerFeedback: AnalyzerFeedback
}

type Exercise = {
  title: string
  slug: string
}

type AutosaveConfig = {
  key: string
  saveInterval: number
}

type EditorPanels = {
  instructions: {
    introduction: string
    debuggingInstructions?: string
    assignment: Assignment
    exampleFiles: File[]
  }
  tests?: {
    testFiles: readonly TestFile[]
    highlightjsLanguage: string
  }
  results: {
    testRunner: {
      averageTestDuration: number
    }
  }
}

export type Props = {
  timeout?: number
  defaultSubmissions: Submission[]
  defaultFiles: File[]
  defaultSettings: Partial<EditorSettings>
  autosave: AutosaveConfig
  panels: EditorPanels
  track: Track
  exercise: Exercise
  iteration: Iteration
  links: Links
  features?: EditorFeatures
}
