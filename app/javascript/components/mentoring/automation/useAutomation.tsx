import { SetStateAction, useCallback, useEffect, useState } from 'react'
import {
  ListState,
  useList,
  usePaginatedRequestQuery,
  Request,
  useHistory,
  removeEmpty,
} from '@/hooks'
import { useTrackList } from '../queue/useTrackList'
import type { QueryStatus } from 'react-query'
import type { AutomationTrack, Representation } from '@/components/types'

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
}

const initialTrackData: AutomationTrack = {
  slug: '',
  title: '',
  iconUrl: '',
  numSubmissions: 0,
}

export function useAutomation(
  representationsRequest: Request,
  tracksRequest: Request,
  cacheKey: string
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
    if (tracks?.length > 0 && selectedTrack === initialTrackData) {
      const foundTrack = tracks.find(
        (t: AutomationTrack) => t.slug == request.query.trackSlug
      )
      setSelectedTrack(foundTrack || tracks[0])
    }
  }, [request.query.trackSlug, selectedTrack, tracks])

  // If only_mentored_solutions === null or undefined remove it completely from query obj and query string
  const handleOnlyMentoredSolutions = useCallback(
    (checked) => {
      const queryObject = { ...request.query }
      if (checked) {
        queryObject.onlyMentoredSolutions = true
      } else delete queryObject.onlyMentoredSolutions

      setQuery(queryObject)
      setPage(1)
      setChecked((checked) => !checked)
    },
    [request.query, setPage, setQuery]
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
    page: request.query.page || 1,
    setPage,
    tracks,
    trackListStatus,
    trackListError,
    isTrackListFetching,
    criteria,
    setCriteria,
    request,
  }
}
