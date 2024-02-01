import { useCallback, useEffect, useRef, useState } from 'react'
import { useDebounce } from '@/hooks'
import { usePaginatedRequestQuery, Request } from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { type QueryStatus } from '@tanstack/react-query'
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
  status: QueryStatus
  error: unknown
  isFetching: boolean
  resolvedData: APIResponse | undefined
  criteria?: string
  setCriteria: (criteria: string) => void
  order: string
  setOrder: (order: string) => void
  page: number
  setPage: (page: number) => void
  checked: boolean
  selectedTrack: AutomationTrack
  handleTrackChange: (track: AutomationTrack) => void
  handleOnlyMentoredSolutions: (checked: boolean) => void
  handlePageResetOnInputChange: (input: string) => void
}

const BLANK_TRACK_DATA: AutomationTrack = {
  slug: '',
  title: '',
  iconUrl: '',
  numSubmissions: 0,
}

export function useAutomation(
  representationsRequest: Request,
  tracks: AutomationTrack[],
  selectedTab: string
): returnMentoringAutomation {
  const [checked, setChecked] = useState(false)
  const [currentData, setCurrentData] = useState<APIResponse | undefined>()
  const [criteria, setCriteria] = useState(
    representationsRequest.query?.criteria
  )

  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(representationsRequest)

  const [selectedTrack, setSelectedTrack] = useState<AutomationTrack>(
    tracks.find((t: AutomationTrack) => t.slug == request.query.trackSlug) ||
      tracks[0] ||
      BLANK_TRACK_DATA
  )

  const CACHE_KEY = [
    'mentor-representations-list',
    selectedTab,
    ...Object.values(request.query),
  ]

  const {
    status,
    error,
    data: resolvedData,
    isFetching,
  } = usePaginatedRequestQuery<APIResponse>(CACHE_KEY, request)

  useEffect(() => {
    if (!isFetching) setCurrentData(resolvedData)
  }, [isFetching, resolvedData])

  const debouncedCriteria = useDebounce(criteria, 500)

  useEffect(() => {
    if (debouncedCriteria === undefined || debouncedCriteria === null) return
    if (debouncedCriteria.length > 2 || debouncedCriteria === '') {
      setRequestCriteria(debouncedCriteria)
    }
  }, [debouncedCriteria, setRequestCriteria])

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

  // timeout is stored in a useRef, so it can be cancelled
  const timer = useRef<number>()

  const handlePageResetOnInputChange = useCallback(
    (input: string) => {
      // clears it on any input
      window.clearTimeout(timer.current)
      if (criteria && (input.length > 2 || input.length === 0)) {
        timer.current = window.setTimeout(() => setPage(1), 500)
      }
    },

    [criteria, setPage]
  )

  return {
    status,
    error,
    isFetching,
    resolvedData: currentData,
    criteria,
    setCriteria,
    order: request.query.order,
    setOrder,
    page: request.query.page || 1,
    setPage,
    checked,
    selectedTrack,
    handleTrackChange,
    handleOnlyMentoredSolutions,
    handlePageResetOnInputChange,
  }
}
