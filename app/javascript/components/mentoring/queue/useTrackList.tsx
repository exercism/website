import { Request, usePaginatedRequestQuery } from '../../../hooks/request-query'
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
  resolvedData: any
} => {
  const { resolvedData, isFetching, status, error } =
    usePaginatedRequestQuery<APIResponse>(cacheKey, request)

  return {
    tracks: resolvedData ? resolvedData.tracks : [],
    status,
    error,
    isFetching,
    resolvedData,
  }
}
