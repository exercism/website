import React from 'react'
import { Assignment } from '../editor/types'
import { Modal } from './Modal'
import { GraphicalIcon } from '../common'

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
      <summary className="--summary">
        {heading}

        <GraphicalIcon icon="plus-circle" className="--closed-icon" />
        <GraphicalIcon icon="minus-circle" className="--open-icon" />
      </summary>
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
    <Modal open={open} onClose={onClose} className="m-editor-hints" {...props}>
      <header>
        <GraphicalIcon icon="hints" category="graphics" />
        <h2>Hints and Tips</h2>
      </header>
      <Hints hints={assignment.generalHints} heading="General" />
      {assignment.tasks.map((task, idx) => (
        <Hints
          key={idx}
          hints={task.hints}
          heading={`${idx + 1}. ${task.title}`}
        />
      ))}
    </Modal>
  )
}
