import React, { useState } from 'react'
import { GraphicalIcon } from '../common'
import { CompleteExerciseModal } from '../modals/CompleteExerciseModal'
import { Iteration } from '../types'

export const CompleteExerciseButton = ({
  endpoint,
  iterations,
}: {
  endpoint: string
  iterations: readonly Iteration[]
}): JSX.Element => {
  const [isModalOpen, setIsModalOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        onClick={() => setIsModalOpen(!isModalOpen)}
        className="btn-primary btn-m"
      >
        <GraphicalIcon icon="check-circle" />
        <span>Mark as complete</span>
      </button>
      <CompleteExerciseModal
        endpoint={endpoint}
        iterations={iterations}
        open={isModalOpen}
      />
    </React.Fragment>
  )
}
