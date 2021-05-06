import React, { useRef, useState } from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { Assignment, AssignmentTask } from './types'
import { TaskHintsModal } from '../modals/TaskHintsModal'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { File } from '../types'

export const InstructionsPanel = ({
  introduction,
  assignment,
  exampleFiles,
  debuggingInstructions,
}: {
  introduction: string
  assignment: Assignment
  exampleFiles: File[]
  debuggingInstructions?: string
}) => (
  <Tab.Panel id="instructions" context={TabsContext}>
    <section className="instructions">
      <div className="c-textual-content --small">
        <Introduction introduction={introduction} />
        <Instructions assignment={assignment} />
        <Debug debuggingInstructions={debuggingInstructions} />
        <ExampleFiles files={exampleFiles} />
      </div>
    </section>
  </Tab.Panel>
)

const ExampleFiles = ({ files }: { files: File[] }) => {
  if (files === null || files === undefined || files.length === 0) {
    return null
  }

  return (
    <>
      <h3 className="text-h3 tw-mt-20">Example files</h3>
      {files.map((file, i) => (
        <React.Fragment key={i}>
          <h4>{file.filename}</h4>
          <pre dangerouslySetInnerHTML={{ __html: file.content }} />
        </React.Fragment>
      ))}
    </>
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
    <>
      <h2>Introduction</h2>
      <div dangerouslySetInnerHTML={{ __html: introduction }} />
    </>
  )
}

const Instructions = ({ assignment }: { assignment: Assignment }) => (
  <>
    <h2>Instructions</h2>
    <div dangerouslySetInnerHTML={{ __html: assignment.overview }} />

    {assignment.tasks.map((task, idx) => (
      <Task key={idx} task={task} open={idx === 0} />
    ))}
  </>
)

const Task = ({ task, open }: { task: AssignmentTask; open?: boolean }) => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const componentRef = useRef<HTMLDivElement>(null)
  const detailsProps = open ? { open: true } : {}

  return (
    <details className="c-details" {...detailsProps}>
      <summary className="--summary">
        <span className="--summary-title">{task.title}</span>
        <span className="--closed-icon">
          <GraphicalIcon icon="chevron-right" />
        </span>
        <span className="--open-icon">
          <GraphicalIcon icon="chevron-down" />
        </span>
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
          className="btn-default btn-small hints-btn"
          onClick={() => {
            setIsModalOpen(true)
          }}
        >
          <GraphicalIcon icon="plus-square" />
          Show Hints
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
    <>
      <h2>How to debug</h2>
      <div dangerouslySetInnerHTML={{ __html: debuggingInstructions }} />
    </>
  )
}
