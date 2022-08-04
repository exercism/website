import React from 'react'
import { AssignmentTask } from '../editor/types'
import { Modal } from './Modal'
import { GraphicalIcon } from '../common'

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
      aria={{ labelledby: 'task-hints-modal-heading' }}
      className="m-editor-hints"
      {...props}
    >
      <div role="document">
        <header>
          <GraphicalIcon icon="hints" category="graphics" />
          <h2 id="task-hints-modal-heading">Hints and Tips</h2>
        </header>
        <div className="single-task-hints">
          <h3>{task.title}</h3>
          {task.hints.map((hint, idx) => (
            <div
              className="c-textual-content --large"
              key={idx}
              dangerouslySetInnerHTML={{ __html: hint }}
            ></div>
          ))}
        </div>
      </div>
    </Modal>
  )
}
