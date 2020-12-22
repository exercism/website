import React from 'react'
import { ExerciseInstructionsTask } from '../editor/types'
import { Modal } from './Modal'

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
    <Modal open={open} onClose={onClose} {...props}>
      <ul>
        {task.hints.map((hint, idx) => (
          <li key={idx} dangerouslySetInnerHTML={{ __html: hint }}></li>
        ))}
      </ul>
    </Modal>
  )
}
