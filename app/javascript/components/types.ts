export type ExerciseStatus =
  | 'published'
  | 'completed'
  | 'iterated'
  | 'started'
  | 'available'
  | 'locked'

export type Exercise =
  | (ExerciseCore & { isUnlocked: true; links: { self: string } })
  | (ExerciseCore & { isUnlocked: false })

export type SolutionForStudent = {
  id: string
  url: string
  status: SolutionStatus
  mentoringStatus: SolutionMentoringStatus
  hasNotifications: boolean
  numMentoringComments: number
  numIterations: number
  exercise: {
    slug: string
  }
  track: {
    title: string
  }
}

export type SolutionStatus = 'started' | 'published' | 'completed' | 'iterated'
export type SolutionMentoringStatus =
  | 'none'
  | 'requested'
  | 'in_progress'
  | 'finished'

export type DiscussionStatus =
  | 'requires_mentor_action'
  | 'requires_student_action'
  | 'finished'

export type CommunitySolution = {
  id: string
  snippet: string
  numLoc: string
  numStars: string
  numComments: string
  publishedAt: string
  language: string
  iterationStatus: IterationStatus
  isOutOfDate: boolean
  author: {
    handle: string
    avatarUrl: string
  }
  exercise: {
    title: string
    iconUrl: string
  }
  track: {
    title: string
    iconUrl: string
    highlightjsLanguage: string
  }

  links: {
    publicUrl: string
    privateUrl: string
  }
}

export type CommunitySolutionContext = 'mentoring' | 'profile' | 'exercise'

type ExerciseCore = {
  slug: string
  title: string
  iconUrl: string
  blurb: string
  difficulty: ExerciseDifficulty
  isRecommended: boolean
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
  student: {
    avatarUrl: string
    handle: string
  }
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
