import { useMemo } from 'react'
import { QueryStatus } from '@tanstack/react-query'
import { usePaginatedRequestQuery, Request } from '@/hooks/request-query'
import { useList } from '@/hooks/use-list'
import { useHistory } from '@/hooks/use-history'
import { useDebounce } from '@/hooks/use-debounce'

import type { MentoredTrack, Representation } from '@/components/types'

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
  const {
    data: resolvedData,
    isFetching,
    status,
    error,
  } = usePaginatedRequestQuery<APIResponse>(
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
    status,
    isFetching,
    criteria: request.query.criteria,
    setCriteria,
    order: request.query.order,
    setOrder,
    page: request.query.page || 1,
    setPage,
    error,
  }
}
