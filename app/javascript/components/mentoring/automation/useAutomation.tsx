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
import { AutomationTrack, Representation } from '../../types'
import { useTrackList } from '../queue/useTrackList'

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
  handleOnlyMentoredSolutions: (checked: boolean) => void
  selectedTrack: AutomationTrack
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

const initialTrackData: AutomationTrack = {
  slug: '',
  title: '',
  iconUrl: '',
  numSubmissions: 0,
}

export function useAutomation(
  representationsRequest: Request,
  representationsWithFeedbackCount: number | undefined,
  representationsWithoutFeedbackCount: number | undefined,
  tracksRequest: Request,
  cacheKey: string,
  withFeedback: boolean
): returnMentoringAutomation {
  const [checked, setChecked] = useState(false)
  const [criteria, setCriteria] = useState(
    representationsRequest.query?.criteria || ''
  )

  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(representationsRequest)

  const {
    resolvedData: tracks,
    status: trackListStatus,
    error: trackListError,
    isFetching: isTrackListFetching,
  } = useTrackList({
    cacheKey: cacheKey,
    request: tracksRequest,
  })

  const [selectedTrack, setSelectedTrack] =
    useState<AutomationTrack>(initialTrackData)

  const { status, resolvedData, latestData, isFetching } =
    usePaginatedRequestQuery<APIResponse>(
      ['mentor-representations-list', request],
      request
    )

  // TODO: refactor this and probably all query with the debounce hook
  useEffect(() => {
    const handler = setTimeout(() => {
      if (criteria.length > 2 || criteria === '') {
        setRequestCriteria(criteria)
      }
    }, 500)

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

      setQuery({ ...request.query, trackSlug: track.slug, page: 1 })
    },
    [setPage, setQuery, request.query]
  )

  // Automatically set a selected track based on query or the lack of it
  useEffect(() => {
    // don't repeat `find` on track change, only when page loads
    if (tracks.length > 0 && selectedTrack === initialTrackData) {
      const foundTrack = tracks.find(
        (t: AutomationTrack) => t.slug == request.query.trackSlug
      )
      setSelectedTrack(foundTrack || tracks[0])
    }
  }, [request.query.trackSlug, selectedTrack, tracks])

  // If only_mentored_solutions === null or undefined remove it completely from query obj and query string
  const handleOnlyMentoredSolutions = useCallback(
    (checked) => {
      const queryObject: { onlyMentoredSolutions?: true } = {}
      if (checked) {
        Object.assign(queryObject, {
          ...request.query,
          onlyMentoredSolutions: true,
        })
      } else {
        delete queryObject.onlyMentoredSolutions
      }
      setQuery(queryObject)
      setPage(1)
      setChecked((checked) => !checked)
    },
    [request.query, setPage, setQuery]
  )

  // Get the proper count number of automation requests for tabs
  const getFeedbackCount = useCallback(
    (withFeedback) => {
      if (withFeedback && resolvedData) {
        return {
          with_feedback: resolvedData.meta.totalCount,
          without_feedback: representationsWithoutFeedbackCount,
        }
      } else if (resolvedData) {
        return {
          with_feedback: representationsWithFeedbackCount,
          without_feedback: resolvedData.meta.totalCount,
        }
      } else {
        return {
          with_feedback: 0,
          without_feedback: 0,
        }
      }
    },
    [
      representationsWithFeedbackCount,
      representationsWithoutFeedbackCount,
      resolvedData,
    ]
  )

  const feedbackCount = useMemo(
    () => getFeedbackCount(withFeedback),
    [getFeedbackCount, withFeedback]
  )

  return {
    handleTrackChange,
    handleOnlyMentoredSolutions,
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
