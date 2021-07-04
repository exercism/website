import React from 'react'
import { UnlockedConcept } from './UnlockedConcept'
import { UnlockedExercise } from './UnlockedExercise'
import { Concept } from '../../CompleteExerciseModal'
import { GraphicalIcon } from '../../../common'
import { Exercise, Track } from '../../../types'
import pluralize from 'pluralize'

export const Unlocks = ({
  unlockedConcepts,
  unlockedExercises,
}: {
  unlockedConcepts: Concept[]
  unlockedExercises: Exercise[]
}): JSX.Element => {
  return (
    <div className="unlocks" data-testid="unlocks">
      {unlockedConcepts.length > 0 ? (
        <div className="unlocked-concepts">
          <h3>
            You&apos;ve unlocked
            <GraphicalIcon icon="concepts" />
            {unlockedConcepts.length}{' '}
            {pluralize('concept', unlockedConcepts.length)}
          </h3>
          <div className="list">
            {unlockedConcepts.map((concept) => (
              <UnlockedConcept key={concept.name} {...concept} />
            ))}
          </div>
        </div>
      ) : null}
      {unlockedExercises.length > 0 ? (
        <div className="unlocked-exercises">
          <h3>
            You&apos;ve unlocked
            <GraphicalIcon icon="exercises" />
            {unlockedExercises.length}{' '}
            {pluralize('exercise', unlockedExercises.length)}
          </h3>
          <div className="list">
            {unlockedExercises.map((exercise) => (
              <UnlockedExercise key={exercise.title} {...exercise} />
            ))}
          </div>
        </div>
      ) : null}
    </div>
  )
}
