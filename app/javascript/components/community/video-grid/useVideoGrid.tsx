import {
  useCallback,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from 'react'
import { usePaginatedRequestQuery, Request, useList, ListState } from '@/hooks'
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
        request.query.trackSlug,
        request.query.page,
      ],
      request
    )

  useLayoutEffect(() => {
    const searchParams = new URLSearchParams(window.location.search)
    const trackSlug = searchParams.get('video_track_slug')
    const page = searchParams.get('video_page')
    const criteria = searchParams.get('video_criteria')
    setQuery({
      trackSlug,
      page,
      criteria,
    })

    if (trackSlug && trackSlug.length > 0) {
      setSelectedTrack(
        // in case a track would be missing
        tracks.find((track) => track.slug == trackSlug) || tracks[0]
      )
    }
    if (criteria && criteria.length > 0) {
      setCriteria(criteria)
    }

    if (page) {
      setPage(Number(page))
    }
  }, [setPage, setQuery, tracks])

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
        pushQueryParams('video_criteria', criteria)
      }
    }, 500)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  const handleTrackChange = useCallback(
    (track: VideoTrack) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)

      pushQueryParams('video_track_slug', track.slug)

      setQuery({
        ...request.query,
        trackSlug: track.slug,
        page: 1,
      })
    },
    [setPage, setQuery, request.query]
  )

  const handlePageTurn = useCallback(
    (page: number) => {
      setPage(page)
      pushQueryParams('video_page', `${page}`)
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

function pushQueryParams(key: string, value: string | number): void {
  const url = new URL(window.location.toString())

  
    if (value && value.length > 0) {
      url.searchParams.set(key, value)
    } else {
      url.searchParams.delete(key)
    }
  
  window.history.pushState({}, '', url)
}
