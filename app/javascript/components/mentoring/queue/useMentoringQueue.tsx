import { useMemo } from 'react'
import { QueryStatus } from '@tanstack/react-query'
import { useDebounce } from '@/hooks'
import { usePaginatedRequestQuery, Request } from '@/hooks/request-query'
import { useHistory } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import type { MentoredTrack, MentoredTrackExercise } from '@/components/types'

export type MentoringRequest = {
  uuid: string
  track: { title: string }
  exercise: { title: string; iconUrl: string }
  student: { handle: string; avatarUrl: string }
  solution: { uuid: string }
  updatedAt: string
  isFavorited: boolean
  haveMentoredPreviously: boolean
  status: string
  tooltipUrl: string
  url: string
}

export type APIResponse = {
  results: MentoringRequest[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

export const useMentoringQueue = ({
  request: initialRequest,
  track,
  exercise,
}: {
  request: Request
  track: MentoredTrack | null
  exercise: MentoredTrackExercise | null
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
  const exerciseSlug = exercise?.slug
  const query = useMemo(() => {
    return {
      ...request.query,
      trackSlug: trackSlug,
      exerciseSlug: exerciseSlug,
    }
  }, [exerciseSlug, request.query, trackSlug])
  const debouncedQuery = useDebounce(query, 500)
  const {
    data: resolvedData,
    isFetching,
    status,
    error,
  } = usePaginatedRequestQuery<APIResponse>(
    ['mentoring-request', debouncedQuery, request],
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
