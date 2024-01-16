import React, { useState, useCallback } from 'react'
import { GraphicalIcon } from '../common'
import { CompleteExerciseModal } from '../modals/CompleteExerciseModal'
import { Iteration } from '../types'

export default function CompleteExerciseButton({
  endpoint,
  iterations,
}: {
  endpoint: string
  iterations: readonly Iteration[]
}): JSX.Element {
  const [isModalOpen, setIsModalOpen] = useState(false)

  const handleModalClose = useCallback(() => {
    setIsModalOpen(false)
  }, [])

  return (
    <React.Fragment>
      <button
        onClick={() => setIsModalOpen(!isModalOpen)}
        className="btn-enhanced btn-m"
      >
        <GraphicalIcon icon="check-circle" />
        <span>Mark as complete</span>
      </button>
      <CompleteExerciseModal
        endpoint={endpoint}
        iterations={iterations}
        open={isModalOpen}
        onClose={handleModalClose}
      />
    </React.Fragment>
  )
}
