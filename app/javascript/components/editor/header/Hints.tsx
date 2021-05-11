import React, { useRef, useState } from 'react'
import { HintsModal } from '../../modals/HintsModal'
import { Assignment } from '../types'
import { Icon } from '../../common'

export function Hints({ assignment }: { assignment: Assignment }) {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)

  return (
    <>
      <HintsModal
        assignment={assignment}
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
      <button
        ref={buttonRef}
        className="hints-btn"
        onClick={() => {
          setIsModalOpen(true)
        }}
      >
        <Icon icon="hints" alt="View all hints" />
      </button>
    </>
  )
}
