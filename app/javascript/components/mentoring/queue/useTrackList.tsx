import { Request, usePaginatedRequestQuery } from '../../../hooks/request-query'
import { MentoredTrack } from '../../types'
import { QueryKey, QueryStatus } from '@tanstack/react-query'

export type APIResponse = {
  tracks: MentoredTrack[]
}

export const useTrackList = ({
  cacheKey,
  request,
}: {
  cacheKey: QueryKey
  request: Request
}): {
  tracks: MentoredTrack[]
  status: QueryStatus
  error: unknown
  isFetching: boolean
  resolvedData: any
} => {
  const {
    data: resolvedData,
    isFetching,
    status,
    error,
  } = usePaginatedRequestQuery<APIResponse>(cacheKey, request)

  return {
    tracks: resolvedData ? resolvedData.tracks : [],
    status,
    error,
    isFetching,
    resolvedData,
  }
}
