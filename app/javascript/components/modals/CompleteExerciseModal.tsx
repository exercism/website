import React, { useState } from 'react'
import { PublishSolutionModal } from './complete-exercise-modal/PublishSolutionModal'
import { ExerciseCompletedModal } from './complete-exercise-modal/ExerciseCompletedModal'
import { TutorialCompletedModal } from './complete-exercise-modal/TutorialCompletedModal'
import { Track, Exercise, Iteration } from '../types'

export type ExerciseCompletion = {
  track: Track
  exercise: CompletedExercise
  conceptProgressions: {
    name: string
    from: number
    to: number
    total: number
  }[]
  unlockedExercises: Exercise[]
  unlockedConcepts: Concept[]
}

export type CompletedExercise = Exercise & { links: { self: string } }

export type Concept = {
  name: string
}

export const CompleteExerciseModal = ({
  endpoint,
  iterations,
  open,
}: {
  endpoint: string
  iterations: readonly Iteration[]
  open: boolean
}): JSX.Element => {
  const [completion, setCompletion] = useState<ExerciseCompletion | null>(null)

  if (completion) {
    return completion.exercise.isTutorial ? (
      <TutorialCompletedModal track={completion.track} open={open} />
    ) : (
      <ExerciseCompletedModal completion={completion} open={open} />
    )
  } else {
    return (
      <PublishSolutionModal
        open={open}
        endpoint={endpoint}
        iterations={iterations}
        onSuccess={(completion) => {
          setCompletion(completion)
        }}
      />
    )
  }
}
