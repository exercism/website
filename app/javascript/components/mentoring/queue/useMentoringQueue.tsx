import { usePaginatedRequestQuery, Request } from '../../../hooks/request-query'
import { useList } from '../../../hooks/use-list'
import { useIsMounted } from 'use-is-mounted'
import { MentoredTrack, MentoredTrackExercise } from '../../types'
import { QueryStatus } from 'react-query'

type MentoringRequest = {
  id: string
  track_title: string
  track_icon_url: string
  exercise_title: string
  mentee_handle: string
  mentee_avatar_url: string
  updated_at: string
  is_starred: boolean
  have_mentored_previously: boolean
  status: string
  tooltip_url: string
  url: string
}

type APIResponse = {
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
  criteria: string
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
  const isMountedRef = useIsMounted()
  const { request, setCriteria, setOrder, setPage } = useList(initialRequest)
  const trackSlug = track?.id
  const exerciseSlug = exercise?.slug
  const {
    resolvedData,
    latestData,
    isFetching,
    status,
    error,
  } = usePaginatedRequestQuery<APIResponse>(
    ['mentoring-request', request.query, trackSlug, exerciseSlug],
    {
      ...request,
      query: {
        ...request.query,
        trackSlug: trackSlug,
        exerciseSlug: exerciseSlug,
      },
      options: {
        enabled: !!track,
      },
    },
    isMountedRef
  )

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
