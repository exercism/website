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
    <>
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
    </>
  )
}
