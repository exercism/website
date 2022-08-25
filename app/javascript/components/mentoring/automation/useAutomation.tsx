import {
  SetStateAction,
  useCallback,
  useEffect,
  useMemo,
  useState,
} from 'react'
import { QueryStatus } from 'react-query'
import { usePaginatedRequestQuery, Request } from '../../../hooks/request-query'
import { useHistory, removeEmpty } from '../../../hooks/use-history'
import { ListState, useList } from '../../../hooks/use-list'
import { AutomationTrack, MentoredTrack, Representation } from '../../types'
import { useTrackList } from '../queue/useTrackList'
import { MOCK_DEFAULT_TRACK } from './mock-data'

export type APIResponse = {
  results: Representation[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

type returnMentoringAutomation = {
  request: ListState
  criteria?: string
  setCriteria: (criteria: string) => void
  order: string
  setOrder: (order: string) => void
  page: number
  setPage: (page: number) => void
  handleTrackChange: (track: AutomationTrack) => void
  selectedTrack: MentoredTrack
  status: QueryStatus
  resolvedData: APIResponse | undefined
  latestData: APIResponse | undefined
  isFetching: boolean
  checked: boolean
  setChecked: React.Dispatch<SetStateAction<boolean>>
  tracks: AutomationTrack[]
  trackListStatus: QueryStatus
  trackListError: unknown
  isTrackListFetching: boolean
  feedbackCount: {
    with_feedback: number | undefined
    without_feedback: number | undefined
  }
}

export function useAutomation(
  representationsRequest: Request,
  representationsWithFeedbackCount: number | undefined,
  representationsWithoutFeedbackCount: number | undefined,
  tracksRequest: Request,
  cacheKey: string,
  withFeedback: boolean
): returnMentoringAutomation {
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(MOCK_DEFAULT_TRACK)

  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(representationsRequest)

  const [checked, setChecked] = useState(false)
  const [criteria, setCriteria] = useState(
    representationsRequest.query?.criteria || ''
  )

  const { status, resolvedData, latestData, isFetching } =
    usePaginatedRequestQuery<APIResponse>(
      ['mentor-representations-list', request.endpoint, request.query],
      request
    )

  useEffect(() => {
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 300)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const handleTrackChange = useCallback(
    (track) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)

      setQuery({ ...request.query, trackSlug: track.slug, page: undefined })
    },
    [setPage, setQuery, request.query]
  )

  const getFeedbackCount = useCallback(
    (withFeedback) => {
      if (withFeedback) {
        return {
          with_feedback: resolvedData?.results.length,
          without_feedback: representationsWithoutFeedbackCount,
        }
      } else {
        return {
          with_feedback: representationsWithFeedbackCount,
          without_feedback: resolvedData?.results.length,
        }
      }
    },
    [
      representationsWithFeedbackCount,
      representationsWithoutFeedbackCount,
      resolvedData?.results.length,
    ]
  )

  const feedbackCount = useMemo(
    () => getFeedbackCount(withFeedback),
    [getFeedbackCount, withFeedback]
  )

  const {
    resolvedData: tracks,
    status: trackListStatus,
    error: trackListError,
    isFetching: isTrackListFetching,
  } = useTrackList({
    cacheKey: cacheKey,
    request: tracksRequest,
  })

  return {
    handleTrackChange,
    selectedTrack,
    status,
    resolvedData,
    latestData,
    isFetching,
    checked,
    setChecked,
    order: request.query.order,
    setOrder,
    page: request.query.page,
    setPage,
    tracks,
    trackListStatus,
    trackListError,
    isTrackListFetching,
    criteria,
    setCriteria,
    feedbackCount,
    request,
  }
}
