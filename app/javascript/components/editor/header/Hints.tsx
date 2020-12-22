import React, { useRef, useState } from 'react'
import { HintsModal } from '../../modals/HintsModal'
import { ExerciseInstructions } from '../types'

export function Hints({
  instructions,
}: {
  instructions: ExerciseInstructions
}) {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const componentRef = useRef<HTMLDivElement>(null)

  return (
    <div ref={componentRef}>
      <HintsModal
        instructions={instructions}
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
      <button
        ref={buttonRef}
        className="btn-small hints-btn"
        onClick={() => {
          setIsModalOpen(true)
        }}
      >
        Hints
      </button>
    </div>
  )
}
