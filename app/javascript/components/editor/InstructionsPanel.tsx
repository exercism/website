import React, { useRef, useState } from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { ExerciseInstructions, ExerciseInstructionsTask } from './types'
import { TaskHintsModal } from '../modals/TaskHintsModal'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { File } from '../types'

export const InstructionsPanel = ({
  introduction,
  instructions,
  exampleFiles,
}: {
  introduction: string
  instructions: ExerciseInstructions
  exampleFiles: File[]
}) => (
  <Tab.Panel id="instructions" context={TabsContext}>
    <section className="instructions">
      <div className="c-textual-content --small">
        <h2>Introduction</h2>
        <div dangerouslySetInnerHTML={{ __html: introduction }} />

        <Instructions instructions={instructions} />
        <ExampleFiles files={exampleFiles} />
      </div>
    </section>
  </Tab.Panel>
)

const ExampleFiles = ({ files }: { files: File[] }) =>
  files.length === 0 ? null : (
    <>
      <h3 className="text-h3 tw-mt-20">Example files</h3>
      {files.map((file) => (
        <>
          <h4 key={file.filename}>{file.filename}</h4>
          <pre
            key={file.content}
            dangerouslySetInnerHTML={{ __html: file.content }}
          />
        </>
      ))}
    </>
  )

const Instructions = ({
  instructions,
}: {
  instructions: ExerciseInstructions
}) => (
  <>
    <h2>Instructions</h2>
    <div dangerouslySetInnerHTML={{ __html: instructions.overview }} />

    {instructions.tasks.map((task, idx) => (
      <InstructionsTask key={idx} task={task} open={idx === 0} />
    ))}
  </>
)

const InstructionsTask = ({
  task,
  open,
}: {
  task: ExerciseInstructionsTask
  open?: boolean
}) => {
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
          className="btn-small-secondary hints-btn"
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
