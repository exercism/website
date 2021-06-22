import { Props as ConceptWidgetProps } from './common/ConceptWidget'
import { Props as ExerciseWidgetProps } from './common/ExerciseWidget'

export type Size = 'small' | 'large'

export type PaginatedResult<T> = {
  results: T
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
  }
}

export type ExerciseType = 'tutorial' | 'concept' | 'practice'

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

export type Concept = {
  name: string
  slug: string
  links: {
    self: string
    tooltip: string
  }
}

export type Contribution = {
  id: string
  value: number
  text: string
  iconUrl: string
  internalUrl?: string
  externalUrl?: string
  earnedOn: string
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

type UserLinks = {
  self?: string
}
export type User = {
  avatarUrl: string
  handle: string
  reputation?: string
  links?: UserLinks
}

export type Exercise =
  | (ExerciseCore & { isUnlocked: true; links: { self: string } })
  | (ExerciseCore & { isUnlocked: false })

export type Student = {
  id: number
  avatarUrl: string
  name: string
  bio: string
  location: string
  languagesSpoken: string[]
  handle: string
  reputation: string
  isFavorited: boolean
  isBlocked: boolean
  trackObjectives: string
  numTotalDiscussions: number
  numDiscussionsWithMentor: number
  links: {
    block: string
    favorite: string
    previousSessions: string
  }
}

export type SolutionForStudent = {
  id: string
  privateUrl: string
  publicUrl: string
  status: SolutionStatus
  mentoringStatus: SolutionMentoringStatus
  hasNotifications: boolean
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
  type: ExerciseType
  title: string
  iconUrl: string
  blurb: string
  difficulty: ExerciseDifficulty
  isRecommended: boolean
  isExternal: boolean
}

export type ExerciseDifficulty = 'easy' | 'medium' | 'hard'

export type File = {
  filename: string
  content: string
  digest?: string
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
  indentSize: number
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

export type StudentTrack = {
  id: string
  webUrl: string
  iconUrl: string
  title: string
  numConcepts: number
  numCompletedConcepts: number
  tags: readonly string[]
  isNew: boolean
  hasNotifications: boolean
  numCompletedExercises: number
  numExercises: number
  lastTouchedAt: string
  isJoined: boolean
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
  files?: File[]
  links: {
    self: string
    solution: string
    files: string
    testRun: string
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
  UNTESTED = 'untested',
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
    isFavorited: boolean
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
  isFavorited: boolean
  postsCount: number
  iterationsCount: number
  createdAt: string
  updatedAt: string
  links: {
    self: string
    posts: string
    markAsNothingToDo: string
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

export type Contributor = {
  rank: number
  avatarUrl: string
  handle: string
  activity: string
  reputation: string
  links: {
    profile: string
  }
}

export type BadgeRarity = 'common' | 'rare' | 'ultimate' | 'legendary'

export type Badge = {
  id: string
  rarity: BadgeRarity
  iconName: string
  name: string
  description: string
  isRevealed: boolean
  unlockedAt: string
  links: {
    reveal: string
  }
}

export type Task = {
  id: string
  title: string
  tags: TaskTags
  track: Pick<Track, 'title' | 'iconUrl'>
  isNew: boolean
  links: {
    githubUrl: string
  }
}

export type TaskTags = {
  action?: TaskAction
  knowledge?: TaskKnowledge
  module?: TaskModule
  size?: TaskSize
  type?: TaskType
}

export type TaskAction = 'create' | 'fix' | 'improve' | 'proofread' | 'sync'
export type TaskKnowledge = 'none' | 'elementary' | 'intermediate' | 'advanced'
export type TaskModule =
  | 'analyzer'
  | 'concept-exercise'
  | 'concept'
  | 'generator'
  | 'practice-exercise'
  | 'representer'
  | 'test-runner'
export type TaskSize = 'tiny' | 'small' | 'medium' | 'large' | 'massive'
export type TaskType = 'ci' | 'coding' | 'content' | 'docker' | 'docs'

export type SiteUpdateContext = 'track' | 'update'

export type SiteUpdateIconType =
  | { type: 'concept'; data: string }
  | { type: 'image'; url: string }

export type SiteUpdateExpandedInfo = {
  author: Contributor
  title: string
  description: string
}

export type SiteUpdate = {
  track: {
    title: string
    iconUrl: string
  }
  text: string
  publishedAt: string
  icon: SiteUpdateIconType
  expanded?: SiteUpdateExpandedInfo
  pullRequest?: PullRequest
  conceptWidget?: ConceptWidgetProps
  exerciseWidget?: ExerciseWidgetProps
  makers: readonly {
    handle: string
    avatarUrl: string
  }[]
}

export type PullRequest = {
  url: string
  title: string
  number: string
  mergedAt: string
  mergedBy: string
}

export type CommunicationPreferences = {
  emailOnMentorStartedDiscussionNotification: boolean
}

export class TrackProgress {
  title: string
  slug: string
  numExercises: number
  numCompletedExercises: number
  numSolutions: number
  numLines: number
  numConceptsLearnt: number
  iconUrl: string

  get completion(): number {
    return (100 * this.numCompletedExercises) / this.numExercises
  }

  // TODO
  get velocity(): number {
    return 9.05
  }

  constructor({
    title,
    slug,
    numExercises,
    numCompletedExercises,
    numConceptsLearnt,
    numSolutions,
    numLines,
    iconUrl,
  }: {
    title: string
    slug: string
    numExercises: number
    numCompletedExercises: number
    numSolutions: number
    numLines: number
    numConceptsLearnt: number
    iconUrl: string
  }) {
    this.title = title
    this.slug = slug
    this.numExercises = numExercises
    this.numCompletedExercises = numCompletedExercises
    this.numConceptsLearnt = numConceptsLearnt
    this.numSolutions = numSolutions
    this.numLines = numLines
    this.iconUrl = iconUrl
  }
}

export class TrackProgressList {
  items: readonly TrackProgress[]

  get numConceptsLearnt(): number {
    return this.items.reduce<number>(
      (sum, track) => (sum += track.numConceptsLearnt),
      0
    )
  }

  get completion(): number {
    return (100 * this.numCompletedExercises) / this.numExercises
  }

  // TODO
  get velocity(): number {
    return 2.52
  }

  get numCompletedExercises(): number {
    return this.items.reduce<number>(
      (sum, track) => (sum += track.numCompletedExercises),
      0
    )
  }

  get numExercises(): number {
    return this.items.reduce<number>(
      (sum, track) => (sum += track.numExercises),
      0
    )
  }

  get numSolutions(): number {
    return this.items.reduce<number>(
      (sum, track) => (sum += track.numSolutions),
      0
    )
  }

  get numLines(): number {
    return this.items.reduce<number>((sum, track) => (sum += track.numLines), 0)
  }

  get length(): number {
    return this.items.length
  }

  sort(): TrackProgressList {
    return new TrackProgressList({
      items: [...this.items]
        .sort((a, b) => (a.completion < b.completion ? -1 : 1))
        .reverse(),
    })
  }

  constructor({ items }: { items: readonly TrackProgress[] }) {
    this.items = items
  }
}

export class MentoredTrackProgress {
  title: string
  slug: string
  iconUrl: string
  numSessions: number
  numStudents: number

  constructor({
    title,
    slug,
    iconUrl,
    numSessions,
    numStudents,
  }: {
    title: string
    slug: string
    iconUrl: string
    numSessions: number
    numStudents: number
  }) {
    this.title = title
    this.slug = slug
    this.iconUrl = iconUrl
    this.numSessions = numSessions
    this.numStudents = numStudents
  }
}

export class MentoredTrackProgressList {
  items: readonly MentoredTrackProgress[]

  sort(): MentoredTrackProgressList {
    return new MentoredTrackProgressList({
      items: [...this.items]
        .sort((a, b) => (a.numSessions < b.numSessions ? -1 : 1))
        .reverse(),
    })
  }

  get numSessions(): number {
    return this.items.reduce<number>(
      (sum, track) => (sum += track.numSessions),
      0
    )
  }

  get numStudents(): number {
    return this.items.reduce<number>(
      (sum, track) => (sum += track.numStudents),
      0
    )
  }

  get sessionRatio(): number {
    return this.numSessions / this.numStudents
  }

  constructor({ items }: { items: readonly MentoredTrackProgress[] }) {
    this.items = items
  }
}

export type ContributionCategoryId =
  | 'publishing'
  | 'mentoring'
  | 'authoring'
  | 'building'
  | 'maintaining'
  | 'other'

export type ContributionCategory = {
  id: ContributionCategoryId
  reputation: number
  metricFull?: string
  metricShort?: string
}

export class TrackContribution {
  id: string | null
  title: string
  iconUrl: string
  categories: readonly ContributionCategory[]

  get totalReputation(): number {
    return this.categories.reduce(
      (sum, category) => sum + category.reputation,
      0
    )
  }

  constructor({
    id,
    title,
    iconUrl,
    categories,
  }: {
    id: string | null
    title: string
    iconUrl: string
    categories: readonly ContributionCategory[]
  }) {
    this.id = id
    this.title = title
    this.iconUrl = iconUrl
    this.categories = categories
  }
}

export class BadgeList {
  items: readonly Badge[]

  sort(): BadgeList {
    return new BadgeList({
      items: [...this.items]
        .sort((a, b) =>
          new BadgeRarityValue(a.rarity).value <
          new BadgeRarityValue(b.rarity).value
            ? -1
            : 1
        )
        .reverse(),
    })
  }

  filter(rarity: BadgeRarity): BadgeList {
    return new BadgeList({
      items: [...this.items].filter((badge) => badge.rarity === rarity),
    })
  }

  get length(): number {
    return this.items.length
  }

  constructor({ items }: { items: readonly Badge[] }) {
    this.items = items
  }
}

class BadgeRarityValue {
  rarity: BadgeRarity

  get value(): number {
    switch (this.rarity) {
      case 'common':
        return 0
      case 'rare':
        return 1
      case 'ultimate':
        return 2
      case 'legendary':
        return 3
    }
  }

  constructor(rarity: BadgeRarity) {
    this.rarity = rarity
  }
}
