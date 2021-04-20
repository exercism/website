import React, { useState } from 'react'
import { GraphicalIcon } from '../common'
import { CompleteExerciseModal } from '../modals/CompleteExerciseModal'

export const CompleteExerciseButton = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element => {
  const [isModalOpen, setIsModalOpen] = useState(false)

  return (
    <React.Fragment>
      <button onClick={() => setIsModalOpen(!isModalOpen)} className="btn-cta">
        <GraphicalIcon icon="check-circle" />
        <span>Mark as complete</span>
      </button>
      <CompleteExerciseModal endpoint={endpoint} open={isModalOpen} />
    </React.Fragment>
  )
}
