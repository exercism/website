import React, { useState } from 'react'
import { PublishSolutionModal } from '../modals/PublishSolutionModal'
import { Iteration } from '../types'

export const PublishSolutionButton = ({
  endpoint,
  iterations,
}: {
  endpoint: string
  iterations: readonly Iteration[]
}): JSX.Element => {
  const [isModalOpen, setIsModalOpen] = useState(false)

  return (
    <React.Fragment>
      <button onClick={() => setIsModalOpen(!isModalOpen)}>
        <span>Publish solution</span>
      </button>
      <PublishSolutionModal
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        className="m-publish-solution"
        endpoint={endpoint}
        iterations={iterations}
      />
    </React.Fragment>
  )
}
