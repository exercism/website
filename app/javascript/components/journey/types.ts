export type MentoringTotals = {
  discussions: number
  students: number
  ratio: number
}

export type MentoringRanks = {
  discussions?: number
  students?: number
}

export type TrackProgressChart = {
  data: number[]
  period: string
}

export class TrackProgress {
  title: string
  slug: string
  numExercises: number
  numCompletedExercises: number
  numCompletedMentoringDiscussions: number
  numInProgressMentoringDiscussions: number
  numQueuedMentoringRequests: number
  numSolutions: number
  numLines: number
  numConceptsLearnt: number
  iconUrl: string
  startedAt: string
  progressChart: TrackProgressChart

  get completion(): number {
    if (this.numExercises === 0) return 0

    return (100 * this.numCompletedExercises) / this.numExercises
  }

  // TODO: (required)
  get velocity(): number | null {
    return null
  }

  constructor({
    title,
    slug,
    numExercises,
    numCompletedExercises,
    numCompletedMentoringDiscussions,
    numInProgressMentoringDiscussions,
    numQueuedMentoringRequests,
    numConceptsLearnt,
    numSolutions,
    numLines,
    iconUrl,
    startedAt,
    progressChart,
  }: {
    title: string
    slug: string
    numExercises: number
    numCompletedMentoringDiscussions: number
    numInProgressMentoringDiscussions: number
    numQueuedMentoringRequests: number
    numCompletedExercises: number
    numSolutions: number
    numLines: number
    numConceptsLearnt: number
    iconUrl: string
    startedAt: string
    progressChart: TrackProgressChart
  }) {
    this.title = title
    this.slug = slug
    this.numExercises = numExercises
    this.numCompletedExercises = numCompletedExercises
    this.numCompletedMentoringDiscussions = numCompletedMentoringDiscussions
    this.numInProgressMentoringDiscussions = numInProgressMentoringDiscussions
    this.numQueuedMentoringRequests = numQueuedMentoringRequests
    this.numConceptsLearnt = numConceptsLearnt
    this.numSolutions = numSolutions
    this.numLines = numLines
    this.iconUrl = iconUrl
    this.startedAt = startedAt
    this.progressChart = progressChart
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
    this.items = items.map((item) => new TrackProgress(item))
  }
}

export class MentoredTrackProgress {
  title: string
  slug: string
  iconUrl: string
  numDiscussions: number
  numStudents: number

  constructor({
    title,
    slug,
    iconUrl,
    numDiscussions,
    numStudents,
  }: {
    title: string
    slug: string
    iconUrl: string
    numDiscussions: number
    numStudents: number
  }) {
    this.title = title
    this.slug = slug
    this.iconUrl = iconUrl
    this.numDiscussions = numDiscussions
    this.numStudents = numStudents
  }
}

export class MentoredTrackProgressList {
  items: readonly MentoredTrackProgress[]
  totals: MentoringTotals
  ranks: MentoringRanks

  constructor({
    items,
    totals,
    ranks,
  }: {
    items: readonly MentoredTrackProgress[]
    totals: MentoringTotals
    ranks: MentoringRanks
  }) {
    this.items = items.map((item) => new MentoredTrackProgress(item))
    this.totals = totals
    this.ranks = ranks
  }

  sort(): MentoredTrackProgressList {
    return new MentoredTrackProgressList({
      totals: this.totals,
      ranks: this.ranks,
      items: [...this.items]
        .sort((a, b) => (a.numDiscussions < b.numDiscussions ? -1 : 1))
        .reverse(),
    })
  }

  get length(): number {
    return this.items.length
  }

  get sessionRatio(): number {
    return this.totals.discussions / this.totals.students
  }
}
