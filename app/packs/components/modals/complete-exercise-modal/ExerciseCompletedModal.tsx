import React from 'react'
import { Modal } from '../Modal'
import { ExerciseIcon } from '../../common'
import { ConceptProgression } from './exercise-completed-modal/ConceptProgression'
import { Unlocks } from './exercise-completed-modal/Unlocks'
import { ExerciseCompletion } from '../CompleteExerciseModal'

export const ExerciseCompletedModal = ({
  open,
  completion,
  ...props
}: {
  open: boolean
  completion: ExerciseCompletion
}): JSX.Element => {
  const {
    track,
    exercise,
    conceptProgressions,
    unlockedExercises,
    unlockedConcepts,
  } = completion

  return (
    <Modal
      open={open}
      className="m-completed-exercise c-completed-exercise-progress"
      onClose={() => {}}
      {...props}
    >
      <header>
        <ExerciseIcon iconUrl={exercise.iconUrl} />
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
      <a href={exercise.links.self} className="btn-primary btn-m">
        Continue
      </a>
    </Modal>
  )
}
