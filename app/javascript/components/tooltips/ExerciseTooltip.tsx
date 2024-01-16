import React from 'react'
import { Exercise, Track, SolutionForStudent } from '@/components/types'
import ExerciseWidget from '@/components/common/ExerciseWidget'
import { useRequestQuery } from '@/hooks/request-query'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ExerciseTooltipSkeleton } from '../common/skeleton/skeletons/ExerciseTooltipSkeleton'

const DEFAULT_ERROR = new Error('Unable to load information')

const ExerciseTooltip = React.forwardRef<
  HTMLDivElement,
  React.HTMLProps<HTMLDivElement> & { endpoint: string }
>(({ endpoint, ...props }, ref) => {
  const { data, error, status } = useRequestQuery<{
    track: Track
    exercise: Exercise
    solution: SolutionForStudent
  }>([endpoint], { endpoint: endpoint, options: {} })

  return (
    <div className="c-exercise-tooltip" {...props} ref={ref}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
        LoadingComponent={() => <ExerciseTooltipSkeleton />}
      >
        {data ? (
          /* If we want the track we need to add a pivot to this,
           * and use track={data.track}*/
          <ExerciseWidget
            exercise={data.exercise}
            solution={data.solution}
            isStatic
          />
        ) : (
          <span>Unable to load information</span>
        )}
      </FetchingBoundary>
    </div>
  )
})

export default ExerciseTooltip
