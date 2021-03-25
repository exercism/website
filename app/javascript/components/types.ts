export type Exercise =
  | (ExerciseCore & { isAvailable: true; links: { self: string } })
  | (ExerciseCore & { isAvailable: false })

export type SolutionForStudent = {
  url: string
  status: SolutionStatus
  hasNotifications: boolean
  numMentoringComments: number
  numIterations: number
  exercise: {
    slug: string
  }
}

export type SolutionStatus =
  | 'started'
  | 'published'
  | 'completed'
  | 'in_progress'

type ExerciseCore = {
  slug: string
  title: string
  iconUrl: string
  blurb: string
  difficulty: ExerciseDifficulty
  isRecommended: boolean
  isCompleted: boolean
}

export type ExerciseDifficulty = 'easy'

export type File = {
  filename: string
  content: string
}

export type APIError = {
  type: string
  message: string
}

export type MentorSessionRequest = {
  id: string
  comment: string
  updatedAt: string
  isLocked: boolean
  user: {
    handle: string
    avatarUrl: string
  }
  links: {
    lock: string
    discussion: string
  }
}
export type MentorSessionTrack = {
  id: string
  title: string
  iconUrl: string
  highlightjsLanguage: string
  medianWaitTime: string
}

export type MentorSessionExercise = {
  id: string
  title: string
  iconUrl: string
}

export type MentorSessionDiscussion = {
  id: string
  isFinished: boolean
  links: {
    posts: string
    markAsNothingToDo?: string
    finish?: string
  }
}
export type Track = {
  id: string
  title: string
  iconUrl: string
}

export type Iteration = {
  uuid: string
  idx: number
  status: IterationStatus
  numComments: number
  unread: boolean
  numEssentialAutomatedComments: number
  numActionableAutomatedComments: number
  numNonActionableAutomatedComments: number
  submissionMethod: SubmissionMethod
  representerFeedback?: RepresenterFeedback
  analyzerFeedback?: AnalyzerFeedback
  createdAt: string
  testsStatus: SubmissionTestsStatus
  isPublished: boolean
  links: {
    self: string
    solution: string
    files: string
  }
}

export type RepresenterFeedback = {
  html: string
  author: {
    name: string
    reputation: number
    avatarUrl: string
    profileUrl: string
  }
}

export type AnalyzerFeedback = {
  summary: string
  comments: readonly AnalyzerFeedbackComment[]
}

export type AnalyzerFeedbackComment = {
  type: 'essential' | 'actionable' | 'informative' | 'celebratory'
  html: string
}

export enum SubmissionTestsStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  PASSED = 'passed',
  FAILED = 'failed',
  ERRORED = 'errored',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

export enum IterationStatus {
  TESTING = 'testing',
  TESTS_FAILED = 'tests_failed',
  ANALYZING = 'analyzing',
  ESSENTIAL_AUTOMATED_FEEDBACK = 'essential_automated_feedback',
  ACTIONABLE_AUTOMATED_FEEDBACK = 'actionable_automated_feedback',
  NON_ACTIONABLE_AUTOMATED_FEEDBACK = 'non_actionable_automated_feedback',
  NO_AUTOMATED_FEEDBACK = 'no_automated_feedback',
}

export enum SubmissionMethod {
  CLI = 'cli',
  API = 'api',
}

export enum RepresentationStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  APPROVED = 'approved',
  DISAPPROVED = 'disapproved',
  INCONCLUSIVE = 'inconclusive',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

export enum AnalysisStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  APPROVED = 'approved',
  DISAPPROVED = 'disapproved',
  INCONCLUSIVE = 'inconclusive',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

export type MentorDiscussion = {
  id: string
  mentor: {
    avatarUrl: string
    handle: string
  }
  isFinished: boolean
  isUnread: boolean
  postsCount: number
  createdAt: string
  links: {
    self: string
  }
}

export type MentoredTrackExercise = {
  slug: string
  title: string
  iconUrl: string
  count: number
  completedByMentor: boolean
}

export type MentoredTrack = {
  id: string
  title: string
  iconUrl: string
  num_solutions_queued: number
  exercises: MentoredTrackExercise[] | undefined
  links: {
    exercises: string
  }
}
