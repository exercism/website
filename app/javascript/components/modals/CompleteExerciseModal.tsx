import React, { useState } from 'react'
import { PublishExerciseModal } from './PublishExerciseModal'
import { ExerciseCompletedModal } from './ExerciseCompletedModal'

export type ExerciseCompletion = {
  exercise: {
    title: string
    iconName: string
  }
  conceptProgressions: {
    name: string
    from: number
    to: number
    total: number
  }[]
  unlockedExercises: {
    title: string
    iconName: string
  }[]
  unlockedConcepts: {
    name: string
  }[]
}

export const CompleteExerciseModal = ({
  endpoint,
  open,
}: {
  endpoint: string
  open: boolean
}): JSX.Element => {
  const [completion, setCompletion] = useState<ExerciseCompletion | null>(null)

  if (completion) {
    return <ExerciseCompletedModal completion={completion} open={open} />
  } else {
    return (
      <PublishExerciseModal
        open={open}
        endpoint={endpoint}
        onSuccess={(completion) => {
          setCompletion(completion)
        }}
      />
    )
  }
}
