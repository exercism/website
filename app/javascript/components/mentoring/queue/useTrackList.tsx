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

export const useTrackList = ({
  request,
}: {
  request: Request
}): { tracks: MentoredTrack[]; isFetching: boolean } => {
  const isMountedRef = useIsMounted()

  const { resolvedData, isFetching } = usePaginatedRequestQuery<{
    mentoredTracks: MentoredTrack[]
  }>('mentored-tracks', request, isMountedRef)

  return { tracks: resolvedData ? resolvedData.mentoredTracks : [], isFetching }
}
