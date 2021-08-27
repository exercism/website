import React, { useRef, useState } from 'react'
import { HintsModal } from '../../modals/HintsModal'
import { Assignment } from '../types'
import { Icon } from '../../common'

export const Hints = ({
  assignment,
}: {
  assignment: Assignment
}): JSX.Element | null => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)

  if (assignment.generalHints.length === 0 && assignment.tasks.length === 0) {
    return null
  }

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
