import React from 'react'
import Modal from 'react-modal'
import { ExerciseInstructionsTask } from '../editor/types'

export const TaskHintsModal = ({
  task,
  open,
  onClose,
  ...props
}: {
  task: ExerciseInstructionsTask
  open: boolean
  onClose: () => void
}): JSX.Element => {
  return (
    <Modal isOpen={open} onRequestClose={onClose} {...props}>
      <ul>
        {task.hints.map((hint, idx) => (
          <li key={idx} dangerouslySetInnerHTML={{ __html: hint }}></li>
        ))}
      </ul>
    </Modal>
  )
}
