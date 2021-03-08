import { QueryStatus } from 'react-query'
import { useIsMounted } from 'use-is-mounted'
import { MentoredTrack } from './useTrackList'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'

export type MentoredTrackExercise = {
  slug: string
  title: string
  iconName: string
  count: number
  completedByMentor: boolean
}

export const useExerciseList = ({
  track,
}: {
  track: MentoredTrack | null
}): {
  exercises: MentoredTrackExercise[] | undefined
  status: QueryStatus
  isFetching: boolean
  error: unknown
} => {
  const isMountedRef = useIsMounted()

  const {
    resolvedData: exercises,
    status,
    isFetching,
    error,
  } = usePaginatedRequestQuery<MentoredTrackExercise[]>(
    ['mentored-exercises', track?.slug],
    {
      endpoint: track?.links.exercises,
      options: {
        enabled: !!track,
        initialData: track?.exercises ? track.exercises : undefined,
      },
    },
    isMountedRef
  )

  return {
    exercises,
    status,
    isFetching,
    error,
  }
}
