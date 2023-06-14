import { SetStateAction, useCallback, useEffect, useRef, useState } from 'react'
import {
  useList,
  usePaginatedRequestQuery,
  Request,
  useHistory,
  removeEmpty,
} from '@/hooks'
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
  isFetching: boolean
  status: QueryStatus
  error: unknown
  resolvedData: APIResponse | undefined
  latestData: APIResponse | undefined
  criteria?: string
  setCriteria: (criteria: string) => void
  order: string
  setOrder: (order: string) => void
  page: number
  setPage: (page: number) => void
  checked: boolean
  setChecked: React.Dispatch<SetStateAction<boolean>>
  selectedTrack: AutomationTrack
  handleTrackChange: (track: AutomationTrack) => void
  handleOnlyMentoredSolutions: (checked: boolean) => void
  handlePageResetOnInputChange: (input: string) => void
}

export function useAutomation(
  representationsRequest: Request,
  tracks: AutomationTrack[]
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

  const [selectedTrack, setSelectedTrack] = useState<AutomationTrack>(
    tracks.find((t: AutomationTrack) => t.slug == request.query.trackSlug) ||
      tracks[0]
  )

  const { status, error, resolvedData, latestData, isFetching } =
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
    resolvedData,
    latestData,
    checked,
    setChecked,
    order: request.query.order,
    setOrder,
    page: request.query.page || 1,
    setPage,
    criteria,
    setCriteria,
    selectedTrack,
    handleTrackChange,
    handleOnlyMentoredSolutions,
    handlePageResetOnInputChange,
  }
}
