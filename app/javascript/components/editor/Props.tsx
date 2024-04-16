import { MentoringStatus } from '../journey/solutions-list/MentoringStatusSelect'
import { IterationsListRequest } from '../student/IterationsList'
import {
  AnalyzerFeedback,
  File,
  MentorDiscussion,
  RepresenterFeedback,
  TestFile,
} from '../types'
import { GptUsage } from './ChatGptFeedback/ChatGptDialog'
import { HelpRecord } from './ChatGptFeedback/useChatGptFeedback'
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
  automatedFeedbackInfo: string
  mentoringRequest: string
  mentorDiscussions: string
  createMentorRequest: string
  discordRedirectPath: string
  forumRedirectPath: string
  markVideoAsSeenEndpoint: string
}

type Track = {
  title: string
  slug: string
  iconUrl: string
  medianWaitTime: number
}

type Iteration = {
  representerFeedback: RepresenterFeedback
  analyzerFeedback: AnalyzerFeedback
}

type Exercise = {
  title: string
  slug: string
  deepDiveYoutubeId: string
  deepDiveBlurb: string
}

export type Solution = {
  uuid: string
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
  aiHelp: HelpRecord
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

type Help = {
  html: string
}

export type Props = {
  timeout?: number
  insider: boolean
  defaultSubmissions: Submission[]
  chatgptUsage: GptUsage
  defaultFiles: File[]
  defaultSettings: Partial<EditorSettings>
  autosave: AutosaveConfig
  panels: EditorPanels
  help: Help
  track: Track
  exercise: Exercise
  iteration?: Iteration
  solution: Solution
  discussion?: MentorDiscussion
  links: Links
  features?: EditorFeatures
  mentoringRequested: boolean
  mentoringStatus: MentoringStatus
  request: IterationsListRequest
  trackObjectives: string
  showDeepDiveVideo: boolean
  hasAvailableMentoringSlot: boolean
}
