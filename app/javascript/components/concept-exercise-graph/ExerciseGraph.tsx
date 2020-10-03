import React, { useState } from 'react'

import { Exercise } from './Exercise'
import { ExerciseConnections } from './ExerciseConnections'

import {
  Exercise as ExerciseType,
  ExerciseGraph as ExerciseGraphInterface,
  ExerciseLayer,
} from './exercise-types'

import './ExerciseGraph.css'

export const ExerciseGraph = ({
  exercises,
  layout,
  connections,
}: ExerciseGraphInterface) => {
  console.log({ exercises, layout, connections })

  const [active, setActive] = useState<string | null>(null)

  const exercisesBySlug = exercises.reduce((memo, exercise) => {
    memo.set(exercise.slug, exercise)
    return memo
  }, new Map<string, ExerciseType>())

  return (
    <figure className="c-exercise-graph">
      <ExerciseConnections connections={connections} activeExercise={active} />
      <div className="track">
        {layout.map((layer: ExerciseLayer, i: number) => (
          <div key={`layer-${i}`} className="layer">
            {layer.map((exerciseSlug) => {
              const exercise = exercisesBySlug.get(exerciseSlug)

              // TODO: fix this error typescript error since it _may_ return undefined
              if (!exercise) return 'no exercise'

              return (
                <Exercise
                  key={exercise.index}
                  uuid={exercise.uuid}
                  index={exercise.index}
                  slug={exercise.slug}
                  concepts={exercise.concepts}
                  prerequisites={exercise.prerequisites}
                  status={exercise.status}
                  isActive={active === exercise.slug}
                  handleEnter={() => setActive(exercise.slug)}
                  handleLeave={() => setActive(null)}
                />
              )
            })}
          </div>
        ))}
      </div>
    </figure>
  )
}
