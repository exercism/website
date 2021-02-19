import React from 'react'
import { Assignment } from '../editor/types'
import { Modal } from './Modal'

const Hints = ({
  heading,
  hints,
}: {
  heading: string
  hints: string[] | undefined
}) => {
  if (hints === undefined || hints.length === 0) {
    return null
  }

  return (
    <details className="c-details">
      <summary className="--summary">{heading}</summary>
      <ul>
        {hints.map((hint, idx) => (
          <li key={idx} dangerouslySetInnerHTML={{ __html: hint }}></li>
        ))}
      </ul>
    </details>
  )
}

export const HintsModal = ({
  assignment,
  open,
  onClose,
  ...props
}: {
  assignment: Assignment
  open: boolean
  onClose: () => void
}): JSX.Element => {
  return (
    <Modal
      open={open}
      onClose={onClose}
      className="modal-editor-hints"
      {...props}
    >
      <Hints hints={assignment.generalHints} heading="General" />
      {assignment.tasks.map((task, idx) => (
        <Hints key={idx} hints={task.hints} heading={task.title} />
      ))}
    </Modal>
  )
}
