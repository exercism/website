type GlossaryEntriesListContextType = Pick<
  GlossaryEntriesListProps,
  | 'links'
  | 'glossaryEntries'
  | 'translationLocales'
  | 'mayCreateTranslationProposals'
  | 'mayManageTranslationProposals'
> & {
  setCriteria: (criteria: string) => void
  setPage: (page: number) => void
  resolvedData?: GlossaryEntriesListData
  request: import('@/hooks/use-list').ListState
  setQuery: (query: Record<string, any>) => void
  isFetching: boolean
  status: 'pending' | 'error' | 'success'
  error?: unknown
}

type Proposal = {
  uuid: string
  type: string
  status: string
  term: string
  translation: string
  proposerId: string | number
  llmInstructions: string
  reviewerId?: string | number | null
  llmFeedback?: string
}

type GlossaryEntry = {
  uuid: string
  locale: string
  term: string
  translation: string
  status: 'unchecked' | 'approved' | 'rejected' | 'proposed'
  llmInstructions: string
  proposalsCount: number
  proposals?: Proposal[]
}

type GlossaryEntriesListData = {
  meta: {
    currentPage: number
    totalPages: number
    totalCount: number
    unscopedTotal: number
  }
  results: GlossaryEntry[]
}

type GlossaryEntriesListProps = {
  glossaryEntries: GlossaryEntry[]
  translationLocales: string[]
  request: {
    endpoint: string
    query?: Record<string, any>
    options: {
      initialData: GlossaryEntriesListData
    }
  }
  links: {
    localizationGlossaryEntriesPath: string
    endpoint: string
    createGlossaryEntry: string
  }
  mayCreateTranslationProposals: boolean
  mayManageTranslationProposals: boolean
}

type GlossaryEntriesShowProps = {
  glossaryEntry: GlossaryEntry
  currentUserId: number
  links: GlossaryEntriesShowLinks
}

type GlossaryEntriesShowLinks = {
  glossaryEntriesListPage: string
  approveLlmTranslation: string
  createProposal: string
  approveProposal: string
  rejectProposal: string
  updateProposal: string
}

type GlossaryEntriesShowContextType = GlossaryEntriesShowProps
