import { Request, usePaginatedRequestQuery } from '../../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { MentoredTrack } from '../../types'
import { QueryStatus } from 'react-query'

export type APIResponse = {
  tracks: MentoredTrack[]
}

export const useTrackList = ({
  cacheKey,
  request,
}: {
  cacheKey: string
  request: Request
}): {
  tracks: MentoredTrack[]
  status: QueryStatus
  error: unknown
  isFetching: boolean
} => {
  const isMountedRef = useIsMounted()

  const { resolvedData, isFetching, status, error } = usePaginatedRequestQuery<
    APIResponse
  >(cacheKey, request, isMountedRef)

  return {
    tracks: resolvedData ? resolvedData.tracks : [],
    status,
    error,
    isFetching,
  }
}
