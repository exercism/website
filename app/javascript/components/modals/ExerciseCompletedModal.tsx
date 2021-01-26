import React from 'react'
import { Modal } from './Modal'
import { GraphicalIcon } from '../common'
import { ConceptProgression } from './exercise-completed-modal/ConceptProgression'
import { UnlockedExercise } from './exercise-completed-modal/UnlockedExercise'
import { UnlockedConcept } from './exercise-completed-modal/UnlockedConcept'
import { ExerciseCompletion } from './CompleteExerciseModal'
import pluralize from 'pluralize'

export const ExerciseCompletedModal = ({
  open,
  completion,
  ...props
}: {
  open: boolean
  completion: ExerciseCompletion
}): JSX.Element => {
  const {
    exercise,
    conceptProgressions,
    unlockedExercises,
    unlockedConcepts,
  } = completion

  return (
    <Modal
      open={open}
      className="m-completed-exercise"
      onClose={() => {}}
      {...props}
    >
      <header>
        <GraphicalIcon icon={exercise.iconName} className="c-exercise-icon" />
        <div className="exercise-title">
          You&apos;ve completed
          <br />
          {exercise.title}!
        </div>
      </header>
      <div className="progressed-concepts">
        {conceptProgressions.map((progression) => (
          <ConceptProgression key={progression.name} {...progression} />
        ))}
      </div>
      <div className="unlocks">
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
      <button className="btn-cta">Continue</button>
    </Modal>
  )
}
