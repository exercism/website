import React from 'react'
import { ExerciseInstructions } from '../editor/types'
import { Modal } from './Modal'

const Hints = ({
  heading,
  hints,
  open,
}: {
  heading: string
  hints: string[] | undefined
  open?: boolean
}) => {
  if (hints === undefined || hints.length === 0) {
    return null
  }

  const props = open ? { open: true } : {}

  return (
    <details className="c-details" {...props}>
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
    <Modal open={open} onClose={onClose} {...props}>
      <Hints hints={instructions.generalHints} heading="General" open={true} />
      {instructions.tasks.map((task, idx) => (
        <Hints key={idx} hints={task.hints} heading={task.title} />
      ))}
    </Modal>
  )
}
