import React from 'react'
import { Assignment } from '../editor/types'
import { Modal } from './Modal'
import { GraphicalIcon } from '../common'

const Hints = ({
  heading,
  hints,
  expanded,
  collapsable,
}: {
  heading: string
  hints: string[] | undefined
  expanded: boolean
  collapsable: boolean
}) => {
  if (hints === undefined || hints.length === 0) {
    return null
  }

  return (
    <details className="c-details" open={expanded}>
      <summary className="--summary">
        <div className="--summary-inner">
          {heading}
          {collapsable ? (
            <>
              <GraphicalIcon icon="plus-circle" className="--closed-icon" />
              <GraphicalIcon icon="minus-circle" className="--open-icon" />
            </>
          ) : null}
        </div>
      </summary>
      {hints.map((hint, idx) => (
        <div
          className="c-textual-content --large"
          key={idx}
          dangerouslySetInnerHTML={{ __html: hint }}
        ></div>
      ))}
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
      <Hints
        hints={assignment.generalHints}
        heading="General"
        expanded={assignment.tasks.length === 0}
        collapsable={assignment.tasks.length > 0}
      />
      {assignment.tasks.map((task, idx) => (
        <Hints
          key={idx}
          hints={task.hints}
          heading={`${idx + 1}. ${task.title}`}
          expanded={false}
          collapsable={true}
        />
      ))}
    </Modal>
  )
}
