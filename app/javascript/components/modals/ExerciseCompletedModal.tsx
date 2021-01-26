import React from 'react'
import { Modal } from './Modal'
import { GraphicalIcon } from '../common'
import { ConceptProgression } from './exercise-completed-modal/ConceptProgression'
import { Unlocks } from './exercise-completed-modal/Unlocks'
import { ExerciseCompletion } from './CompleteExerciseModal'

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
      {unlockedExercises.length !== 0 || unlockedConcepts.length !== 0 ? (
        <Unlocks
          unlockedExercises={unlockedExercises}
          unlockedConcepts={unlockedConcepts}
        />
      ) : null}
      <button className="btn-cta">Continue</button>
    </Modal>
  )
}
