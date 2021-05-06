import React, { useRef, useState } from 'react'
import { HintsModal } from '../../modals/HintsModal'
import { Assignment } from '../types'

export function Hints({ assignment }: { assignment: Assignment }) {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const componentRef = useRef<HTMLDivElement>(null)

  return (
    <div ref={componentRef}>
      <HintsModal
        assignment={assignment}
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
      <button
        ref={buttonRef}
        className="btn-default btn-s hints-btn"
        onClick={() => {
          setIsModalOpen(true)
        }}
      >
        Hints
      </button>
    </div>
  )
}
