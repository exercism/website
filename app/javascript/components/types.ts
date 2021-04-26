export type ExerciseStatus =
  | 'published'
  | 'completed'
  | 'iterated'
  | 'started'
  | 'available'
  | 'locked'

export type ExerciseAuthorship = {
  exercise: Exercise
  track: Track
}

export type Contribution = {
  id: string
  value: number
  text: string
  iconUrl: string
  internalUrl?: string
  externalUrl?: string
  awardedAt: string
  track?: {
    title: string
    iconUrl: string
  }
}

export type Testimonial = {
  id: string
  content: string
  student: {
    avatarUrl: string
    handle: string
  }
  exercise: {
    title: string
    iconUrl: string
  }
  track: {
    title: string
    iconUrl: string
  }
  createdAt: string
  isRevealed: boolean
  links: {
    reveal: string
  }
}

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
  updatedAt: string
  exercise: {
    slug: string
    title: string
    iconUrl: string
  }
  track: {
    slug: string
    title: string
    iconUrl: string
  }
}

export type SolutionStatus = 'started' | 'published' | 'completed' | 'iterated'
export type SolutionMentoringStatus =
  | 'none'
  | 'requested'
  | 'in_progress'
  | 'finished'

export type DiscussionStatus =
  | 'awaiting_mentor'
  | 'awaiting_student'
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
  isTutorial: boolean
  isExternal: boolean
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
  track: {
    title: string
  }
  student: {
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
  links: {
    self: string
  }
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
  numConcepts: number
  numExercises: number
  numSolutions: number
  links: {
    self: string
    exercises: string
    concepts: string
  }
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

export type MentorDiscussionStatus =
  | 'awaiting_student'
  | 'awaiting_mentor'
  | 'mentor_finished'
  | 'finished'

export type MentorDiscussionFinishedBy = 'mentor' | 'student'

export type MentorDiscussion = {
  id: string
  status: MentorDiscussionStatus
  finishedAt?: string
  finishedBy?: MentorDiscussionFinishedBy
  student: {
    avatarUrl: string
    handle: string
    isStarred: boolean
  }
  mentor: {
    avatarUrl: string
    handle: string
  }
  track: {
    title: string
    iconUrl: string
  }
  exercise: {
    title: string
    iconUrl: string
  }
  isFinished: boolean
  isUnread: boolean
  postsCount: number
  createdAt: string
  updatedAt: string
  links: {
    self: string
    posts: string
    finish: string
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
  numSolutionsQueued: number
  exercises: MentoredTrackExercise[] | undefined
  links: {
    exercises: string
  }
}

export type ExerciseType = 'concept' | 'practice' | 'tutorial'
