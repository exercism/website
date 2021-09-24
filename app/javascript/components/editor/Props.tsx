import { File } from '../types'
import { Submission, Assignment, EditorSettings } from './types'

export type EditorFeatures = {
  theme: boolean
  keybindings: boolean
}

type Links = {
  runTests: string
  back: string
}

type Track = {
  title: string
  slug: string
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
    tests: string
    highlightjsLanguage: string
  }
  results: {
    averageTestDuration: number
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
  links: Links
  features?: EditorFeatures
}
