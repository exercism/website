import { Request, usePaginatedRequestQuery } from '../../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { MentoredTrackExercise } from './useExerciseList'
import { QueryStatus } from 'react-query'

export type MentoredTrack = {
  slug: string
  title: string
  iconUrl: string
  count: number
  exercises: MentoredTrackExercise[] | undefined
  links: {
    exercises: string
  }
}

export type APIResponse = {
  mentoredTracks: MentoredTrack[]
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
    tracks: resolvedData ? resolvedData.mentoredTracks : [],
    status,
    error,
    isFetching,
  }
}
