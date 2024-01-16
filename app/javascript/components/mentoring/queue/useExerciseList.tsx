import { QueryStatus } from '@tanstack/react-query'
import { MentoredTrack, MentoredTrackExercise } from '../../types'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'

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
  const {
    data: exercises,
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
    }
  )

  return {
    exercises,
    status,
    isFetching,
    error,
  }
}
