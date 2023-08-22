import React, { useState } from 'react'
import { PublishSolutionModal } from '../modals/PublishSolutionModal'
import { Iteration } from '../types'

export default function PublishSolutionButton({
  endpoint,
  iterations,
}: {
  endpoint: string
  iterations: readonly Iteration[]
}): JSX.Element {
  const [isModalOpen, setIsModalOpen] = useState(false)

  return (
    <div className="publish-section">
      <div className="header">
        <h3>Publish your solution</h3>
      </div>
      <p>
        By publishing your solution, you earn reputation and help others
        discover new tips and tricks.
      </p>

      <button
        onClick={() => setIsModalOpen(!isModalOpen)}
        className="btn-enhanced btn-m publish-btn"
      >
        Publish solution
      </button>
      <PublishSolutionModal
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        className="m-publish-solution"
        endpoint={endpoint}
        iterations={iterations}
      />
    </div>
  )
}
