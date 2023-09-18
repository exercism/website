import React from 'react'
import { default as ExerciseStatusDot } from './ExerciseStatusDot'

export function ExerciseStatusChart({
  exercisesData,
  links,
}: {
  exercisesData: { [slug: string]: [string, string] }
  links: { exercise: string; tooltip: string }
}): JSX.Element {
  return (
    <div className="exercises">
      {Object.keys(exercisesData).map((key) => {
        const slug = key
        const status = exercisesData[key][0]
        const type = exercisesData[key][1]

        const dotLinks = {
          tooltip: links.tooltip.replace('$SLUG', slug),
          exercise:
            status !== 'locked'
              ? links.exercise.replace('$SLUG', slug)
              : undefined,
        }

        if (
          status !== 'locked' &&
          status !== 'available' &&
          status !== 'started' &&
          status !== 'iterated' &&
          status !== 'completed' &&
          status !== 'published'
        ) {
          throw new Error('Invalid status')
        }

        return (
          <ExerciseStatusDot
            key={slug}
            exerciseStatus={status}
            type={type}
            links={dotLinks}
          />
        )
      })}
    </div>
  )
}

export default ExerciseStatusChart
