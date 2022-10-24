import { useCallback, useEffect, useState } from 'react'
import {
  usePaginatedRequestQuery,
  Request,
  useList,
  useHistory,
  removeEmpty,
  ListState,
} from '@/hooks'
import { VideoTrack } from '../../types'
import { CommunityVideoAuthor } from '@/components/track/approaches-elements/community-videos/types'

export type VideoData = {
  title: string
  author: CommunityVideoAuthor
  embedUrl: string
  thumbnailUrl: string
}

export type APIResponse = {
  results: VideoData[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

export type HandleTrackChangeType = (track: VideoTrack) => void

export type UseVideoGridReturnType = {
  handleTrackChange: HandleTrackChangeType
  selectedTrack: VideoTrack
  resolvedData: APIResponse | undefined
  latestData: APIResponse | undefined
  isFetching: boolean
  order: string
  setOrder: (order: string) => void
  page: number
  setPage: (page: number) => void
  criteria: string
  setCriteria: (criteria: string) => void
  request: ListState
}

export function useVideoGrid(
  videoRequest: Request,
  tracks: VideoTrack[],
  selectedTrackSlug: string | null
): UseVideoGridReturnType {
  const initialTrack =
    tracks.find((track) => track.slug == selectedTrackSlug) || tracks[0]
  const [criteria, setCriteria] = useState(videoRequest.query?.criteria || '')
  const [selectedTrack, setSelectedTrack] = useState(initialTrack)

  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(videoRequest)

  const { resolvedData, latestData, isFetching } =
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
    (track: VideoTrack) => {
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
