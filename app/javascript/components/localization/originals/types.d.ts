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
  translations: {
    uuid: string
    locale: string
    status: string
  }[]
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
