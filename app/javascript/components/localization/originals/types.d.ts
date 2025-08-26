type OriginalsListContextType = Pick<
  OriginalsListProps,
  'links' | 'originals'
> & {
  setCriteria: (criteria: string) => void
  setPage: (page: number) => void
  resolvedData?: OriginalsListData
  request: import('@/hooks/use-list').ListState
  setQuery: (query: Record<string, any>) => void
  isFetching: boolean
  status: 'pending' | 'error' | 'success'
  error?: unknown
}

type Original = {
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

type OriginalsListData = {
  meta: {
    currentPage: number
    totalPages: number
    totalCount: number
    unscopedTotal: number
  }
  results: Original[]
}

type OriginalsListProps = {
  originals: Original[]
  request: {
    endpoint: string
    query?: Record<string, any>
    options: {
      initialData: OriginalsListData
    }
  }
  links?: { localizationOriginalsPath: string; endpoint: string }
}

type OriginalsShowProps = {
  original: Original
  currentUserId: number
  links: OriginalsShowLinks
}

type OriginalsShowLinks = {
  approveLlmTranslation: string
  originalsListPage: string
  createProposal: string
  approveProposal: string
  rejectProposal: string
  updateProposal: string
}

type OriginalsShowContextType = OriginalsShowProps
