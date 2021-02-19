import React from 'react'
import { AssignmentTask } from '../editor/types'
import { Modal } from './Modal'

export const TaskHintsModal = ({
  task,
  open,
  onClose,
  ...props
}: {
  task: AssignmentTask
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
      <ul>
        {task.hints.map((hint, idx) => (
          <li key={idx} dangerouslySetInnerHTML={{ __html: hint }}></li>
        ))}
      </ul>
    </Modal>
  )
}
