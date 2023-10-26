import React, { useState } from 'react'
import { PublishSolutionModal } from './complete-exercise-modal/PublishSolutionModal'
import { ExerciseCompletedModal } from './complete-exercise-modal/ExerciseCompletedModal'
import { TutorialCompletedModal } from './complete-exercise-modal/TutorialCompletedModal'
import { Track, Exercise, Iteration } from '../types'
import { ModalProps } from './Modal'

export type ExerciseCompletion = {
  track: Track
  exercise: CompletedExercise
  conceptProgressions: {
    name: string
    from: number
    to: number
    total: number
    links: { self: string }
  }[]
  unlockedExercises: Exercise[]
  unlockedConcepts: Concept[]
}

export type CompletedExercise = Exercise & { links: { self: string } }

export type Concept = {
  name: string
  links: {
    self: string
  }
}

export const CompleteExerciseModal = ({
  open,
  onClose,
  endpoint,
  iterations,
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  iterations: readonly Iteration[]
}): JSX.Element => {
  const [completion, setCompletion] = useState<ExerciseCompletion | null>(null)

  if (completion) {
    return completion.exercise.type == 'tutorial' ? (
      <TutorialCompletedModal completion={completion} open={open} />
    ) : (
      <ExerciseCompletedModal completion={completion} open={open} />
    )
  } else {
    return (
      <PublishSolutionModal
        open={open}
        onClose={onClose}
        endpoint={endpoint}
        iterations={iterations}
        onSuccess={(completion) => {
          setCompletion(completion)
        }}
      />
    )
  }
}
