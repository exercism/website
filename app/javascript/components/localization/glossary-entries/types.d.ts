type GlossaryEntriesListContextType = Pick<
  GlossaryEntriesListProps,
  'links' | 'glossaryEntries'
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

type GlossaryEntry = {
  uuid: string
  locale: string
  term: string
  translation: string
  status: 'unchecked' | 'approved' | 'rejected'
  llmInstructions: string
  proposalsCount: number
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
  request: {
    endpoint: string
    query?: Record<string, any>
    options: {
      initialData: GlossaryEntriesListData
    }
  }
  links?: { localizationGlossaryEntriesPath: string; endpoint: string }
}

type GlossaryEntriesShowProps = {
  original: GlossaryEntry
  currentUserId: number
  links: GlossaryEntriesShowLinks
}

type GlossaryEntriesShowLinks = {
  approveLlmTranslation: string
  originalsListPage: string
  createProposal: string
  approveProposal: string
  rejectProposal: string
  updateProposal: string
}

type GlossaryEntriesShowContextType = GlossaryEntriesShowProps
