import { useCallback, useEffect, useRef, useState } from 'react'
import {
  usePaginatedRequestQuery,
  useList,
  useQueryParams,
  type Request,
  type ListState,
} from '@/hooks'
import type {
  CommunityVideoType,
  CommunityVideoAuthor,
  VideoTrack,
} from '@/components/types'

export type VideoData = {
  title: string
  author: CommunityVideoAuthor
  embedUrl: string
  thumbnailUrl: string
}

export type APIResponse = {
  results: CommunityVideoType[]
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
  tracks: VideoTrack[]
): UseVideoGridReturnType {
  const initialTrack =
    tracks.find(
      (t) =>
        t.slug ===
        new URLSearchParams(window.location.search).get('video_track_slug')
    ) || tracks[0]

  const [criteria, setCriteria] = useState(videoRequest.query?.criteria || '')
  const [selectedTrack, setSelectedTrack] = useState<VideoTrack>(initialTrack)

  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(videoRequest)

  const { resolvedData, latestData, isFetching } =
    usePaginatedRequestQuery<APIResponse>(
      [
        'community-video-grid-key',
        request.query.criteria,
        request.query.videoTrackSlug,
        request.query.videoPage,
      ],
      request
    )

  // don't refetch everything with an empty criteria after mounting
  const didMount = useRef(false)
  useEffect(() => {
    if (!didMount.current) {
      didMount.current = true
      return
    }

    const handler = setTimeout(() => {
      if (criteria.length > 2 || criteria === '') {
        setRequestCriteria(criteria)
        setQuery({ ...request.query, criteria })
      }
    }, 500)

    return () => {
      clearTimeout(handler)
    }

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [criteria])

  const handleTrackChange = useCallback(
    (track: VideoTrack) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)

      setQuery({
        ...request.query,
        videoTrackSlug: track.slug,
        videoPage: 1,
      })
    },
    [setPage, setQuery, request.query]
  )

  useQueryParams(request.query)

  const handlePageTurn = useCallback(
    (page: number) => {
      setPage(page)
    },
    [setPage]
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
    setPage: handlePageTurn,
    criteria,
    setCriteria,
    request,
  }
}
