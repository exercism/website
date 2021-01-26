import React from 'react'
import { UnlockedExercise } from './UnlockedExercise'
import { UnlockedConcept } from './UnlockedConcept'
import { Concept, Exercise } from '../CompleteExerciseModal'
import { GraphicalIcon } from '../../common'
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
      {unlockedExercises.length > 0 ? (
        <div className="unlocked-exercises">
          <h3>
            You&apos;ve unlocked
            <GraphicalIcon icon="exercises" />
            {unlockedExercises.length}{' '}
            {pluralize('exercise', unlockedExercises.length)}
          </h3>
          {unlockedExercises.map((exercise) => (
            <UnlockedExercise key={exercise.title} {...exercise} />
          ))}
        </div>
      ) : null}
      {unlockedConcepts.length > 0 ? (
        <div className="unlocked-concepts">
          <h3>
            You&apos;ve unlocked
            <GraphicalIcon icon="concepts" />
            {unlockedConcepts.length}{' '}
            {pluralize('concept', unlockedConcepts.length)}
          </h3>
          {unlockedConcepts.map((concept) => (
            <UnlockedConcept key={concept.name} {...concept} />
          ))}
        </div>
      ) : null}
    </div>
  )
}
