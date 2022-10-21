import { useCallback, useEffect, useState } from 'react'
import { usePaginatedRequestQuery, Request } from '../../../hooks/request-query'
import { useHistory, removeEmpty } from '../../../hooks/use-history'
import { useList } from '../../../hooks/use-list'
import { AutomationTrack, Representation } from '../../types'

export type APIResponse = {
  results: Representation[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

const initialTrackData: AutomationTrack = {
  slug: '',
  title: '',
  iconUrl: '',
  numSubmissions: 0,
}

export function useVideoGrid(
  videoRequest: Request,
  tracks: AutomationTrack[]
): any {
  const [criteria, setCriteria] = useState(videoRequest.query?.criteria || '')
  const [selectedTrack, setSelectedTrack] = useState(tracks[0])

  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(videoRequest)

  const { status, resolvedData, latestData, isFetching } =
    usePaginatedRequestQuery<APIResponse>(
      ['community-video-grid-key', request],
      request
    )

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

  return {
    handleTrackChange,
    selectedTrack,
    resolvedData,
    latestData,
    isFetching,
    order: request.query.order,
    setOrder,
    page: request.query.page,
    setPage,
    criteria,
    setCriteria,
    request,
  }
}
