import React from 'react'
import { Exercise, Track, SolutionForStudent } from '../types'
import { ExerciseWidget } from '../common'
import { useRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { Loading } from './Loading'

const DEFAULT_ERROR = new Error('Unable to load information')

const ExerciseTooltip = React.forwardRef<
  HTMLDivElement,
  React.HTMLProps<HTMLDivElement> & { endpoint: string }
>(({ endpoint, ...props }, ref) => {
  const { data, error, status } = useRequestQuery<{
    track: Track
    exercise: Exercise
    solution: SolutionForStudent
  }>(endpoint, { endpoint: endpoint, options: {} })

  return (
    <div className="c-exercise-tooltip" {...props} ref={ref}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
        LoadingComponent={() => <Loading alt="Unable to load exercises" />}
      >
        {data ? (
          /* If we want the track we need to add a pivot to this,
           * and use track={data.track}*/
          <ExerciseWidget
            exercise={data.exercise}
            solution={data.solution}
            renderAsLink={false}
          />
        ) : (
          <span>Unable to load information</span>
        )}
      </FetchingBoundary>
    </div>
  )
})

export default ExerciseTooltip
