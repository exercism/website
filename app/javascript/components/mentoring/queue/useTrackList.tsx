import { Request, usePaginatedRequestQuery } from '../../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { MentoredTrackExercise } from './useExerciseList'

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
  isFetching: boolean
} => {
  const isMountedRef = useIsMounted()

  const { resolvedData, isFetching } = usePaginatedRequestQuery<APIResponse>(
    cacheKey,
    request,
    isMountedRef
  )

  return {
    tracks: resolvedData ? resolvedData.mentoredTracks : [],
    isFetching,
  }
}
