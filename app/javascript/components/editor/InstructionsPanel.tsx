import React, { useContext, useRef, useState } from 'react'
import { Tab } from '../common/Tab'
import { TabsContext, TasksContext } from '../Editor'
import { Assignment, AssignmentTask } from './types'
import { TaskHintsModal } from '../modals/TaskHintsModal'
import { GraphicalIcon, Icon } from '../common'
import { useHighlighting } from '../../utils/highlight'

export const InstructionsPanel = ({
  introduction,
  assignment,
  debuggingInstructions,
}: {
  introduction: string
  assignment: Assignment
  debuggingInstructions?: string
}) => {
  const ref = useHighlighting<HTMLDivElement>()

  return (
    <Tab.Panel id="instructions" context={TabsContext}>
      <section className="instructions-pane" ref={ref}>
        <div className="c-textual-content --small">
          <Introduction introduction={introduction} />
          <Instructions assignment={assignment} />
          <Debug debuggingInstructions={debuggingInstructions} />
        </div>
      </section>
    </Tab.Panel>
  )
}

const Introduction = ({ introduction }: { introduction: string }) => {
  if (
    introduction === undefined ||
    introduction === null ||
    introduction.length === 0
  ) {
    return null
  }

  return (
    <div className="introduction">
      <h2>Introduction</h2>
      <div
        className="content"
        dangerouslySetInnerHTML={{ __html: introduction }}
      />
    </div>
  )
}

const Instructions = ({ assignment }: { assignment: Assignment }) => {
  const { current } = useContext(TasksContext)

  return (
    <div className="instructions">
      <h2>Instructions</h2>
      <div
        className="content"
        dangerouslySetInnerHTML={{ __html: assignment.overview }}
      />

      {assignment.tasks.map((task, idx) => (
        <Task key={idx} task={task} open={task.id === current} idx={idx} />
      ))}
    </div>
  )
}

const Task = ({
  task,
  open,
  idx,
}: {
  task: AssignmentTask
  open?: boolean
  idx: number
}) => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const componentRef = useRef<HTMLDivElement>(null)
  const detailsProps = open ? { open: true } : {}

  return (
    <details className="c-details task" {...detailsProps}>
      <summary className="--summary">
        <div className="--summary-inner">
          <div className="task-marker">Task {idx + 1}</div>
          <span className="summary-title">{task.title}</span>
          <span className="--closed-icon">
            <GraphicalIcon icon="chevron-right" />
          </span>
          <span className="--open-icon">
            <GraphicalIcon icon="chevron-down" />
          </span>
        </div>
      </summary>
      <div dangerouslySetInnerHTML={{ __html: task.text }} />

      <div ref={componentRef}>
        <TaskHintsModal
          task={task}
          open={isModalOpen}
          onClose={() => setIsModalOpen(false)}
        />
        <button
          ref={buttonRef}
          className="btn-default btn-s hints-btn"
          onClick={() => {
            setIsModalOpen(true)
          }}
        >
          <span>Stuck? Reveal Hints</span>
          <Icon icon="modal" alt="Opens in a modal" />
        </button>
      </div>
    </details>
  )
}

const Debug = ({
  debuggingInstructions,
}: {
  debuggingInstructions?: string
}) => {
  if (
    debuggingInstructions === undefined ||
    debuggingInstructions === null ||
    debuggingInstructions.length === 0
  ) {
    return null
  }

  return (
    <div className="debug-info">
      <h2>How to debug</h2>
      <div dangerouslySetInnerHTML={{ __html: debuggingInstructions }} />
    </div>
  )
}
