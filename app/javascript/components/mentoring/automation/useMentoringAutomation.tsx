import { useMemo } from 'react'
import { usePaginatedRequestQuery, Request } from '../../../hooks/request-query'
import { useList } from '../../../hooks/use-list'
import { MentoredTrack, Representation } from '../../types'
import { QueryStatus } from 'react-query'
import { useDebounce } from '../../../hooks/use-debounce'
import { useHistory } from '../../../hooks/use-history'

export type RepresentationsRequest = {
  uuid: string
  trackTitle: string
  trackIconUrl: string
  exerciseTitle: string
  exerciseIconUrl: string
  studentHandle: string
  studentAvatarUrl: string
  updatedAt: string
  isFavorited: boolean
  haveMentoredPreviously: boolean
  status: string
  tooltipUrl: string
  url: string
}

export type APIResponse = {
  results: Representation[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

export const useMentoringAutomation = ({
  request: initialRequest,
  track,
}: {
  request: Request
  track: MentoredTrack | null
}): {
  criteria?: string
  setCriteria: (criteria: string) => void
  order: string
  setOrder: (order: string) => void
  page: number
  setPage: (page: number) => void
  resolvedData: APIResponse | undefined
  latestData: APIResponse | undefined
  isFetching: boolean
  status: QueryStatus
  error: unknown
} => {
  const { request, setCriteria, setOrder, setPage } = useList(initialRequest)
  const trackSlug = track?.slug
  const query = useMemo(() => {
    return {
      ...request.query,
      trackSlug: trackSlug,
    }
  }, [request.query, trackSlug])
  const debouncedQuery = useDebounce(query, 500)
  const { resolvedData, latestData, isFetching, status, error } =
    usePaginatedRequestQuery<APIResponse>(
      ['mentoring-automation', debouncedQuery],
      {
        ...request,
        query: debouncedQuery,
        options: {
          ...request.options,
          enabled: !!track,
        },
      }
    )

  useHistory({ pushOn: debouncedQuery })

  return {
    resolvedData,
    latestData,
    status,
    isFetching,
    criteria: request.query.criteria,
    setCriteria,
    order: request.query.order,
    setOrder,
    page: request.query.page,
    setPage,
    error,
  }
}
