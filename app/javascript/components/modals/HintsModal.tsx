import React from 'react'
import { ExerciseInstructions } from '../editor/types'
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
  instructions,
  open,
  onClose,
  ...props
}: {
  instructions: ExerciseInstructions
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
      <Hints hints={instructions.generalHints} heading="General" />
      {instructions.tasks.map((task, idx) => (
        <Hints key={idx} hints={task.hints} heading={task.title} />
      ))}
    </Modal>
  )
}
