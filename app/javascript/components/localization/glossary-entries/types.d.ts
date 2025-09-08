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
  prettyType: ReactI18NextChildren | Iterable<ReactI18NextChildren>
  title: ReactI18NextChildren | Iterable<ReactI18NextChildren>
  usageDetails: ReactI18NextChildren | Iterable<ReactI18NextChildren>
  uuid: string
  key: string
  value: string
  translations: Translation[]
}

type Translation = {
  uuid: string
  locale: string
  status: string
  value?: string
  proposal?: string[]
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
